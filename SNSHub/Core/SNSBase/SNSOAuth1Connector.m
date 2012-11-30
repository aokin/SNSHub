//
//  SNSOAuth1Connector.m
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth1Connector.h"
#import "CategoryUtil.h"
#import "SNSSignatureRequest.h"
#import "SNSOAuth1Authorize.h"

@implementation SNSOAuth1Connector

- (void)dealloc
{
    SNS_RELEASE(_requestToken);
    SNS_RELEASE(_requestTokenSecret);
    
    SNS_RELEASE(_oauthToken);
    SNS_RELEASE(_oauthTokenSecret);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[RequestTokenKey, RequestTokenSecretKey, OAuthCallbackConfirmedKey, OAuthTokenKey, OAuthTokenSecretKey]];
        [self setIsSignatureEnable:YES];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theRequestToken = [userDefaults objectForKey:[[self keyObserver] objectForKey:RequestTokenKey]];
    NSString *theRequestTokenSecret = [userDefaults objectForKey:[[self keyObserver] objectForKey:RequestTokenSecretKey]];
    BOOL theOAuthCallbackConfirmed = [userDefaults boolForKey:[[self keyObserver] objectForKey:OAuthCallbackConfirmedKey]];
    NSString *theOAuthToken = [userDefaults objectForKey:[[self keyObserver] objectForKey:OAuthTokenKey]];
    NSString *theOAuthTokenSecret = [userDefaults objectForKey:[[self keyObserver] objectForKey:OAuthTokenSecretKey]];
    
    [self setRequestToken:theRequestToken];
    [self setRequestTokenSecret:theRequestTokenSecret];
    [self setOauthCallbackConfirmed:theOAuthCallbackConfirmed];
    [self setOauthToken:theOAuthToken];
    [self setOauthTokenSecret:theOAuthTokenSecret];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];
    
    if ([(SNSOAuth1Authorize *)[self authorize] authorizeStage] == RequestTokenStage) {
        NSString *theRequestToken = [authInfo objectForKey:@"oauth_token"];
        NSString *theRequestTokenSecret = [authInfo objectForKey:@"oauth_token_secret"];
        BOOL theOAuthCallbackConfirmed = [[authInfo objectForKey:@"oauth_callback_confirmed"] boolValue];
        
        [self setRequestToken:theRequestToken];
        [self setRequestTokenSecret:theRequestTokenSecret];
        [self setOauthCallbackConfirmed:theOAuthCallbackConfirmed];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:[self requestToken] forKey:[[self keyObserver] objectForKey:RequestTokenSecretKey]];
        [userDefaults setObject:[self requestTokenSecret]forKey:[[self keyObserver] objectForKey:RequestTokenKey]];
        [userDefaults setBool:[self oauthCallbackConfirmed] forKey:[[self keyObserver] objectForKey:OAuthCallbackConfirmedKey]];
    } else {
        NSString *theOAuthToken = [authInfo objectForKey:@"oauth_token"];
        NSString *theOAuthTokenSecret = [authInfo objectForKey:@"oauth_token_secret"];
        
        [self setOauthToken:theOAuthToken];
        [self setOauthTokenSecret:theOAuthTokenSecret];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:[self oauthToken] forKey:[[self keyObserver] objectForKey:OAuthTokenKey]];
        [userDefaults setObject:[self oauthTokenSecret] forKey:[[self keyObserver] objectForKey:OAuthTokenSecretKey]];
    }
}

#pragma mark Request

- (NSString *)generateBaseString:(NSString *)httpMethod url:(NSString *)url authorizeParams:(NSDictionary *)authorizeParams
{
    NSArray *sortedKeys = [[authorizeParams allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *pairs = SNS_AUTORELEASE([@[] mutableCopy]);
    for (NSString *key in sortedKeys) {
        id value = [authorizeParams objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [value URLEncodedString]]];
        }
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

- (BOOL)isLoggedIn
{
    return [self oauthToken] && YES;
}

- (NSMutableDictionary *)generateAuthorize:(NSDictionary *)httpParams methodName:(NSString *)methodName httpMethod:(NSString *)httpMethod
{
    NSMutableDictionary *authorizeParam = SNS_AUTORELEASE([@{} mutableCopy]);
    [authorizeParam addEntriesFromDictionary:[self getRequiredHeader]];
    if ([self parameterExcludeSignature]) {
        [authorizeParam addEntriesFromDictionary:httpParams];
        [self setParameterExcludeSignature:NO];
    }
    
    NSString *baseString = [self generateBaseString:httpMethod
                                                url:methodName
                                    authorizeParams:authorizeParam];
    NSString *signature = [self generateSignature:baseString];
    
    [authorizeParam setObject:signature forKey:@"oauth_signature"];
    return authorizeParam;
}

- (void)createRequestWithMethodName:(NSString *)methodName
                         httpMethod:(NSString *)httpMethod
                             params:(NSDictionary *)params
                       postDataType:(PostDataType)postDataType
                   httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    [self setAuthorize:[self getSNSAuthorize]];
    [self readAuthInfo];
    
    // Step 1.
    // Check if the user has been logged in.
	if (![self isLoggedIn]) {
        if ([[self delegate] respondsToSelector:@selector(connectorNotAuthorized:)]) {
            [[self delegate] connectorNotAuthorized:self];
        }
        return;
	}
    
    [[self request] disconnect];
    
    NSMutableDictionary *httpParams = SNS_AUTORELEASE([@{} mutableCopy]);
    [httpParams addEntriesFromDictionary:params];
    [httpParams addEntriesFromDictionary:[self getRequiredParams]];
    
    NSMutableDictionary *authorizeParam = [self generateAuthorize:params methodName:methodName httpMethod:httpMethod];
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithDictionary:httpHeaderFields];
    [headerFields setObject:[self generateAuthorizeString:authorizeParam] forKey: @"Authorization"];
    
    if (![self isSignatureEnable]) {
        self.request = [SNSRequest requestWithAccessToken:nil
                                                      url:methodName
                                               httpMethod:httpMethod
                                                   params:httpParams
                                             postDataType:postDataType
                                         httpHeaderFields:headerFields
                                                 delegate:self];
    } else {
        self.request = [SNSSignatureRequest requestWithAccessToken:nil
                                                               url:methodName
                                                        httpMethod:httpMethod
                                                            params:httpParams
                                                      postDataType:postDataType
                                                  httpHeaderFields:headerFields
                                                          delegate:self];
    }
    
	[[self request] connect];
}

- (void)authorize:(SNSAuthorize *)authorize didSucceedWithAuthInfo:(id)authInfo
{
    if ([(SNSOAuth1Authorize *)authorize authorizeStage] == RequestTokenStage) {
        [self writeAuthInfo:authInfo];
        [[self authorize] startAuthorize];
    } else if ([(SNSOAuth1Authorize *)authorize authorizeStage] == AccessTokenStage) {
        [super authorize:authorize didSucceedWithAuthInfo:authInfo];
    }
}

@end
