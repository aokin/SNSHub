//
//  SNSSignatureRequest.m
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSSignatureRequest.h"

@implementation SNSSignatureRequest

+ (SNSSignatureRequest *)requestWithURL:(NSString *)url
                    httpMethod:(NSString *)httpMethod
                        params:(NSDictionary *)params
                  postDataType:(PostDataType)postDataType
              httpHeaderFields:(NSDictionary *)httpHeaderFields
                      delegate:(id<SNSRequestDelegate, SNSSignatureRequestDelegate>)delegate
{
    SNSSignatureRequest *request = SNS_AUTORELEASE([[[self class] alloc] init]);
    
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
                              delegate:(id<SNSRequestDelegate, SNSSignatureRequestDelegate>)delegate
{
    // add the access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if (accessToken) {
        [mutableParams setObject:accessToken forKey:@"access_token"];
    }
    
    return [SNSSignatureRequest requestWithURL:url
                           httpMethod:httpMethod
                               params:mutableParams
                         postDataType:postDataType
                     httpHeaderFields:httpHeaderFields
                             delegate:delegate];
}

- (void)connect
{
    // calu sig
    if ([[self delegate] respondsToSelector:@selector(request:willCalculateSignature:)]) {
        [self setParams:[[self delegate] request:self willCalculateSignature:[self params]]];
    }
    
    [super connect];
}

@end
