//
//  BaseApi.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "BaseApi.h"

#define ApiSuffixName                   @"Api"
#define ConnectorSuffixName             @"Connector"

@implementation BaseApi

- (void)dealloc
{
    SNS_RELEASE(_connector);
    SNS_RELEASE(_lastParams);
    SNS_RELEASE(_accountInfo);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

+ (id)createObject:(NSString *)apiName appKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI
{
    Class class = NSClassFromString([NSString stringWithFormat:@"%@%@", [apiName capitalizedString], ApiSuffixName]);
    id object = SNS_AUTORELEASE([[class alloc] init]);
    [[object connector] setAppKey:appKey];
    [[object connector] setAppSecret:appSecret];
    [[object connector] setRedirectURI:redirectURI];
    return object;
}

+ (id)createObject:(NSString *)apiName appKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI appID:(NSString *)appID
{
    Class class = NSClassFromString([NSString stringWithFormat:@"%@%@", [apiName capitalizedString], ApiSuffixName]);
    id object = SNS_AUTORELEASE([[class alloc] init]);
    [[object connector] setAppID:appID];
    [[object connector] setAppKey:appKey];
    [[object connector] setAppSecret:appSecret];
    [[object connector] setRedirectURI:redirectURI];
    return object;
}

- (void)clean
{
    [[self connector] clearAuthInfo];
}

- (id)init
{
    self = [super init];
    if (self) {
        // remove api suffix name
        NSString *apiFullName = NSStringFromClass([self class]);
        NSString *apiName = [apiFullName stringByReplacingOccurrencesOfString:ApiSuffixName withString:@""];
        
        Class class = NSClassFromString([NSString stringWithFormat:@"%@%@", [apiName capitalizedString], ConnectorSuffixName]);
        SNSConnector *connector = SNS_AUTORELEASE([[class alloc] init]);
        [connector setDelegate:self];
        [self setConnector:connector];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self connector] forKey:NSStringFromClass([[self connector] class])];
    [aCoder encodeObject:[self accountInfo] forKey:@"AccountInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        NSString *apiFullName = NSStringFromClass([self class]);
        NSString *apiName = [apiFullName stringByReplacingOccurrencesOfString:ApiSuffixName withString:@""];
        
        Class class = NSClassFromString([NSString stringWithFormat:@"%@%@", [apiName capitalizedString], ConnectorSuffixName]);
        SNSConnector *connector = [aDecoder decodeObjectForKey:NSStringFromClass(class)];
        [connector setDelegate:self];
        [self setConnector:connector];
        
        AccountInfo *accountInfo = [aDecoder decodeObjectForKey:@"AccountInfo"];
        [self setAccountInfo:accountInfo];
    }
    return self;
}

- (BOOL)isLogin
{
    return [[self connector] isLoggedIn];
}

- (BOOL)isAllowShare
{
    return [[self connector] isAllowShare];
}

- (void)setIsAllowShare:(BOOL)isAllowShare
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isAllowShare forKey:[[[self connector] keyObserver] objectForKey:AllowShareKey]];
    
    return [[self connector] setIsAllowShare:isAllowShare];
}

- (void)login
{
	[[self connector] login];
}

- (void)logout
{
    [[self connector] logout];
    [self clean];
    [self setConnector:nil];
    [self setAccountInfo:nil];
}

- (void)connectorNotAuthorized:(SNSConnector *)connector
{
    [self logout];
    [self login];
}
- (void)connectorAuthorizeExpired:(SNSConnector *)connector
{
    [self logout];
    [self login];
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    //    NSLog(@"User login successful.");
    //    NSMutableDictionary *params = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    //    if ([[[[self connector] authorize] oauthVersion] isEqualToString:@"1.0"]) {
    //        [params setObject:[[self connector] userID] forKey:@"user_id"];
    //    } else {
    //        [params setObject:[[[self connector] keyObserver] userID] forKey:@"uid"];
    //        [params setObject:[NSNumber numberWithDouble:[[self connector] expiresIn]] forKey:@"exprie_time"];
    //    }
    //
    //    [[self connector] getRequestWithMethodName:[self userInfoMethod] params:params];
}

- (void)connector:(SNSConnector *)connector didFailToLogInWithError:(NSError *)error
{
    NSLog(@"User login fail.");
    
    //    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(loginFail:withError:)]) {
    //        [self.delegate loginFail:userCancelled withError:error];
    //    }
}

- (void)connectorDidLogout:(SNSConnector *)connector
{
    NSLog(@"User logout successful.");
    //    NSString *methodName = [kSinaAPI_Account_EndSession stringByAppendingString:RETURN_JSON_FORMAT];
    //    [[self connector] loadRequestWithMethodName:methodName httpMethod:HTTPGetMethod params:nil postDataType:PostDataTypeNormal httpHeaderFields:nil];
}

- (void)connector:(SNSConnector *)connector requestDidFailWithError:(NSError *)error
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:@(ResultFail) forKey:ResultKey];
    [result setValue:@([error code]) forKey:ErrorCodeKey];
    [result setValue:error forKey:ErrorInfoKey];
    [result setValue:[[connector request] httpMethod] forKey:ServiceNameKey];
    
    if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didGetError:)]) {
        [[self delegate] didGetError:result];
    }
    
    SNS_RELEASE(result);
}

@end
