//
//  SNSOAuth1Authorize.m
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth1Authorize.h"
#import "CategoryUtil.h"
#import "ConstantsDefinition.h"

@implementation SNSOAuth1Authorize

- (void)dealloc
{
    SNS_RELEASE(_oauthToken);
    SNS_RELEASE(_oauthTokenSecret);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (NSString *)getRequestTokenURL
{
    return @"";
}

- (NSString *)generateBaseString:(NSString *)httpMethod url:(NSString *)url authorizeParams:(NSDictionary *)authorizeParams
{
    NSArray *sortedKeys = [[authorizeParams allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *pairs = SNS_AUTORELEASE([@[] mutableCopy]);
    for (NSString *key in sortedKeys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[authorizeParams objectForKey:key] URLEncodedString]]];
    }
    
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", httpMethod, [url URLEncodedString], [[pairs componentsJoinedByString:@"&"] URLEncodedString]];
    
    return baseString;
}

- (NSString *)generateSignature:(NSString *)baseString
{
    NSString *key = [[[self appSecret] URLEncodedString] stringByAppendingString:@"&"];
    if ([self oauthTokenSecret]) {
        key = [key stringByAppendingString:[[self oauthTokenSecret] URLEncodedString]];
    }
    NSString *signature = [[baseString HMACSHA1EncodedDataWithKey:key] base64EncodedString];
    
    return signature;
}

- (NSString *)generateAuthorizeString:(NSDictionary *)authorizeParams
{
    NSArray *sortedKeys = [[authorizeParams allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *pairs = SNS_AUTORELEASE([@[] mutableCopy]);
    for (NSString *key in sortedKeys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, [[authorizeParams objectForKey:key] URLEncodedString]]];
    }
    
    NSString *authorizeString = [NSString stringWithFormat:@"OAuth %@", [pairs componentsJoinedByString:@", "]];
    return authorizeString;
}

- (void)prepareAuthorize
{
    [self setAuthorizeStage:RequestTokenStage];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self redirectURI], @"oauth_callback", nil];
    
    NSMutableDictionary *authorizeParams = [NSMutableDictionary dictionaryWithDictionary:[self addAuthorizeParams]];
    [authorizeParams addEntriesFromDictionary:params];
    
    NSString *baseString = [self generateBaseString:HTTPPostMethod url:[self getRequestTokenURL] authorizeParams:authorizeParams];
    NSString *signature = [self generateSignature:baseString];
    [authorizeParams setObject:signature forKey:@"oauth_signature"];
    
    NSString *authorizeString = [self generateAuthorizeString:authorizeParams];
    
    NSDictionary *headerFields = [NSDictionary dictionaryWithObjectsAndKeys:authorizeString, @"Authorization", nil];
    
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getRequestTokenURL]
                                   httpMethod:HTTPPostMethod
                                       params:nil
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:headerFields
                                     delegate:self];
    
    [[self request] connect];
}

- (void)startAuthorize
{
    [self setAuthorizeStage:AccessTokenStage];

    NSMutableDictionary *params = SNS_AUTORELEASE([@{} mutableCopy]);
    
    [params setValue:[self oauthToken] forKey:@"oauth_token"];
    
    NSString *urlString = [SNSRequest serializeURL:[self getAuthorizeBaseURL]
                                            params:params
                                        httpMethod:HTTPGetMethod];
    
    SNSAuthorizeWebView *webView = [[SNSAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
    SNS_RELEASE(webView);
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:code, @"oauth_verifier", [self oauthToken], @"oauth_token", nil];
    
    NSMutableDictionary *authorizeParams = [NSMutableDictionary dictionaryWithDictionary:[self addAuthorizeParams]];
    [authorizeParams addEntriesFromDictionary:params];
    
    NSString *baseString = [self generateBaseString:HTTPPostMethod url:[self getAccessTokenBaseURL] authorizeParams:authorizeParams];
    NSString *signature = [self generateSignature:baseString];
    [authorizeParams setObject:signature forKey:@"oauth_signature"];
    
    NSString *authorizeString = [self generateAuthorizeString:authorizeParams];
    
    NSDictionary *headerFields = [NSDictionary dictionaryWithObjectsAndKeys:authorizeString, @"Authorization", nil];
    
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getAccessTokenBaseURL]
                                   httpMethod:HTTPPostMethod
                                       params:params
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:headerFields
                                     delegate:self];
    
    [[self request] connect];
}

- (void)authorizeWebView:(SNSAuthorizeWebView *)webView didReceiveAuthorizeInfo:(id)authorizeInfo
{
    [webView hide:YES];
    
    NSString *verifyCode = [authorizeInfo objectForKey:@"oauth_verifier"];
    
    if (![verifyCode isEmpty]) {
        [self requestAccessTokenWithAuthorizeCode:verifyCode];
    }
}

- (void)request:(SNSRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    
    NSLog(@"Access Token Info ======> %@", result);
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([[theRequest url] isEqualToString:[self getRequestTokenURL]] ||
            [[theRequest url] isEqualToString:[self getAccessTokenBaseURL]]) {
            [self setOauthToken:[result objectForKey:@"oauth_token"]];
            [self setOauthTokenSecret:[result objectForKey:@"oauth_token_secret"]];
            success = [self oauthToken] && [self oauthTokenSecret];
            
            if (success && [[self delegate] respondsToSelector:@selector(authorize:didSucceedWithAuthInfo:)]) {
                [[self delegate] authorize:self didSucceedWithAuthInfo:result];
            }
        }
    }
    
    // should not be possible
    if (!success && [[self delegate] respondsToSelector:@selector(authorize:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:ErrorDomain
                                             code:ErrorCodeSDK
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", ErrorCodeAuthorizeError]
                                                                              forKey:ErrorCodeKey]];
        [[self delegate] authorize:self didFailWithError:error];
    }
}

@end
