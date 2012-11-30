//
//  SNSOAuth2Connector.m
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth2Connector.h"
#import "SNSSignatureRequest.h"

@implementation SNSOAuth2Connector

- (void)dealloc
{
    SNS_RELEASE(_accessToken);
    SNS_RELEASE(_expiresTime);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[ExpiresInKey, AllowShareKey, AccessTokenKey, ExpiresTimeKey, RefreshTokenKey]];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isAllowShare = [userDefaults boolForKey:[[self keyObserver] objectForKey:AllowShareKey]];
    NSInteger theExpiresIn = [userDefaults integerForKey:[[self keyObserver] objectForKey:ExpiresInKey]];
    NSString *theAccessToken = [userDefaults objectForKey:[[self keyObserver] objectForKey:AccessTokenKey]];
    NSString *theRefreshToken = [userDefaults objectForKey:[[self keyObserver] objectForKey:RefreshTokenKey]];
    NSDate *theExpiresTime = [userDefaults objectForKey:[[self keyObserver] objectForKey:ExpiresTimeKey]];
    
    [self setIsAllowShare:isAllowShare];
    [self setExpiresIn:theExpiresIn];
    [self setAccessToken:theAccessToken];
    [self setExpiresTime:theExpiresTime];
    [self setRefreshToken:theRefreshToken];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];

    NSString *theAccessToken = [authInfo objectForKey:@"access_token"];
    NSString *theRefreshToken = [authInfo objectForKey:@"refresh_token"];
    NSInteger theExpiresIn = [[authInfo objectForKey:[self getExpiresInName]] integerValue];
    
    [self setExpiresIn:theExpiresIn];
    [self setAccessToken:theAccessToken];
    [self setExpiresTime:[[NSDate date] dateByAddingTimeInterval:theExpiresIn]];
    [self setRefreshToken:theRefreshToken];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:[[self keyObserver] objectForKey:AllowShareKey]];
    [userDefaults setInteger:[self expiresIn] forKey:[[self keyObserver] objectForKey:ExpiresInKey]];
    [userDefaults setObject:[self accessToken] forKey:[[self keyObserver] objectForKey:AccessTokenKey]];
    [userDefaults setObject:[self expiresTime] forKey:[[self keyObserver] objectForKey:ExpiresTimeKey]];
    [userDefaults setObject:[self refreshToken] forKey:[[self keyObserver] objectForKey:RefreshTokenKey]];
}

- (BOOL)isAuthorizeExpired
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval dueTime = [[self expiresTime] timeIntervalSince1970];
    // expire in last 5 minutes
    if (dueTime - now <= 86400) {
        // force to log out
        return YES;
    }
    return NO;
}

- (BOOL)isLoggedIn
{
    return [self accessToken] && YES;
}

- (void)createRequestWithMethodName:(NSString *)methodName
                         httpMethod:(NSString *)httpMethod
                             params:(NSDictionary *)params
                       postDataType:(PostDataType)postDataType
                   httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    [self readAuthInfo];
    
	if (![self isLoggedIn]) {
        if ([[self delegate] respondsToSelector:@selector(connectorNotAuthorized:)]) {
            [[self delegate] connectorNotAuthorized:self];
        }
        return;
	}
    
    if ([self isAuthorizeExpired]) {
        if ([[self delegate] respondsToSelector:@selector(connectorAuthorizeExpired:)]) {
            [[self delegate] connectorAuthorizeExpired:self];
        }
        return;
    }
    
    [[self request] disconnect];
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [allParams addEntriesFromDictionary:[self getRequiredParams]];
    
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithDictionary:httpHeaderFields];
    
    if (![self isSignatureEnable]) {
        self.request = [SNSRequest requestWithAccessToken:[self accessToken]
                                                      url:methodName
                                               httpMethod:httpMethod
                                                   params:allParams
                                             postDataType:postDataType
                                         httpHeaderFields:headerFields
                                                 delegate:self];
    } else {
        self.request = [SNSSignatureRequest requestWithAccessToken:[self accessToken]
                                                               url:methodName
                                                        httpMethod:httpMethod
                                                            params:allParams
                                                      postDataType:postDataType
                                                  httpHeaderFields:headerFields
                                                          delegate:self];
    }
    
	[[self request] connect];
}

@end
