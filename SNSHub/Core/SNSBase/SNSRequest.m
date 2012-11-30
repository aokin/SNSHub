//
//  SNSRequest.m
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSRequest.h"
#import "CategoryUtil.h"

#import "ConstantsDefinition.h"

@interface SNSRequest (Private)

+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;
- (NSMutableData *)postBody;

- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;
@end


@implementation SNSRequest

@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize httpHeaderFields;
@synthesize delegate;

#pragma mark - WBRequest Life Circle

- (void)dealloc
{
    SNS_RELEASE(url);
    SNS_RELEASE(httpMethod);
    SNS_RELEASE(params);
    SNS_RELEASE(httpHeaderFields);
    
    SNS_RELEASE(responseData);
    
    [connection cancel];
    SNS_RELEASE(connection);
    SNS_RELEASE(delegate);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

#pragma mark - WBRequest Private Methods

+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody
{
    NSMutableData *body = [NSMutableData data];
    
    if (postDataType == PostDataTypeNormal)
    {
        [SNSRequest appendUTF8Body:body dataString:[SNSRequest stringFromDictionary:params]];
    }
    else if (postDataType == PostDataTypeMultipart)
    {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", StringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", StringBoundary];
        
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        
        [SNSRequest appendUTF8Body:body dataString:bodyPrefixString];
        
        for (id key in [params keyEnumerator])
		{
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]]))
			{
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
			
			[SNSRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
			[SNSRequest appendUTF8Body:body dataString:bodyPrefixString];
		}
		
		if ([dataDictionary count] > 0)
		{
			for (id key in dataDictionary)
			{
				NSObject *dataParam = [dataDictionary valueForKey:key];
				
				if ([dataParam isKindOfClass:[UIImage class]])
				{
					NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
					[SNSRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[SNSRequest appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:imageData];
				}
				else if ([dataParam isKindOfClass:[NSData class]])
				{
					[SNSRequest appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
					[SNSRequest appendUTF8Body:body dataString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:(NSData*)dataParam];
				}
				[SNSRequest appendUTF8Body:body dataString:bodySuffixString];
			}
		}
    }
    
    return body;
}

- (void)handleResponseData:(NSData *)data
{
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)])
    {
        [delegate request:self didReceiveRawData:data];
    }
	
    
	NSError *error = nil;
	id result = [self parseJSONData:data error:&error];
    
	
	if (error) {
		[self failedWithError:error];
	}
	else
	{
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)])
		{
            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
	}
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error
{
    id result = [data objectFromJSONData];
	
	if (!result) {
        NSString *resultString = SNS_AUTORELEASE([[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding]);
#ifdef DEBUG
        NSLog(@"Response String %@", resultString);
#endif
        
        if (![resultString hasPrefix:@"{"]) {
            NSString *jsonString = [resultString convertToJSONObject];
            result = [jsonString objectFromJSONString];
        }
        
        if (!result) {
            if (error != nil) {
                *error = [self errorWithCode:ErrorCodeSDK
                                    userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", ErrorCodeParseError]
                                                                         forKey:ErrorCodeKey]];
            }
        }
    }
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		if ([result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"] intValue] != 200) {
			if (error != nil) {
				*error = [self errorWithCode:ErrorCodeInterface userInfo:result];
			}
		}
	}
	
	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:ErrorDomain code:code userInfo:userInfo];
}

- (void)failedWithError:(NSError *)error
{
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)])
	{
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark - WBRequest Public Methods

+ (SNSRequest *)requestWithURL:(NSString *)url
                    httpMethod:(NSString *)httpMethod
                        params:(NSDictionary *)params
                  postDataType:(PostDataType)postDataType
              httpHeaderFields:(NSDictionary *)httpHeaderFields
                      delegate:(id<SNSRequestDelegate>)delegate
{
    SNSRequest *request = SNS_AUTORELEASE([[[self class] alloc] init]);
    
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    
    return request;
}

+ (SNSRequest *)requestWithAccessToken:(NSString *)accessToken
                                   url:(NSString *)url
                            httpMethod:(NSString *)httpMethod
                                params:(NSDictionary *)params
                          postDataType:(PostDataType)postDataType
                      httpHeaderFields:(NSDictionary *)httpHeaderFields
                              delegate:(id<SNSRequestDelegate>)delegate
{
    // add the access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if (accessToken) {
        [mutableParams setObject:accessToken forKey:@"access_token"];
    }

    return [SNSRequest requestWithURL:url
                           httpMethod:httpMethod
                               params:mutableParams
                         postDataType:postDataType
                     httpHeaderFields:httpHeaderFields
                             delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    if (![httpMethod isEqualToString:HTTPGetMethod])
    {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [SNSRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)connect
{
    NSString *urlString = [SNSRequest serializeURL:url params:params httpMethod:httpMethod];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:TimeoutInterval];
    
    [request setHTTPMethod:httpMethod];
    
    if ([httpMethod isEqualToString:HTTPPostMethod])
    {
        if (postDataType == PostDataTypeMultipart)
        {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", StringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [request setHTTPBody:[self postBody]];
    }
    
    for (NSString *key in [httpHeaderFields keyEnumerator])
    {
        [request setValue:[httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }

    DLog(@"HTTP URL ======> %@", [self url]);
    DLog(@"HTTP Params ======> %@", [self params]);
    DLog(@"HTTP Method ======> %@", [self httpMethod]);
    DLog(@"HTTP Header ======> %@", [self httpHeaderFields]);

    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect
{
    SNS_RELEASE(responseData);
    
    [connection cancel];
    SNS_RELEASE(connection);
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	responseData = [[NSMutableData alloc] init];
	
	if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)])
    {
		[delegate request:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	[self handleResponseData:responseData];
    
    SNS_RELEASE(responseData);
    
    [connection cancel];
    SNS_RELEASE(connection);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	[self failedWithError:error];
	
    SNS_RELEASE(responseData);
    
    [connection cancel];
    SNS_RELEASE(connection);
}

@end
