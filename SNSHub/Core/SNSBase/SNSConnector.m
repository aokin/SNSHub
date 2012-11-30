//
//  SNSConnector.m
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSConnector.h"
#import "CategoryUtil.h"
#import "SNSSignatureRequest.h"

#define AppIDKey                @"AppIDKey"
#define AppKeyKey               @"AppKeyKey"
#define AppSecretKey            @"AppSecretKey"
#define RedirectURIKey          @"RedirectURIKey"

@implementation SNSConnector

- (void)dealloc
{
    SNS_RELEASE(_appID);
    SNS_RELEASE(_appKey);
    SNS_RELEASE(_appSecret);
    SNS_RELEASE(_redirectURI);
    SNS_RELEASE(_userName);
    SNS_RELEASE(_identifier);

    SNS_RELEASE(_keyObserver);
    SNS_RELEASE(_settingParams);

    [[self request] setDelegate:nil];
    [[self request] disconnect];
    SNS_RELEASE(_request);

    [[self authorize] setDelegate:nil];
    SNS_RELEASE(_authorize);

    SNS_RELEASE(_delegate);
#if !ARC_ENABLED
    [super dealloc];
#endif
}

#pragma mark - SNSEngine Life Circle

- (id)init
{
    if (self = [super init]) {
        [self setIsUserExclusive:NO];
        [self setKeyObserver:SNS_AUTORELEASE([@{} mutableCopy])];
        [self registerKey:@[AppIDKey, AppKeyKey, AppSecretKey, RedirectURIKey]];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)  {
        [self setKeyObserver:[aDecoder decodeObjectForKey:NSStringFromClass([self class])]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self keyObserver] forKey:NSStringFromClass([self class])];
}

- (void)readAuthInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *theAppID = [userDefaults objectForKey:[[self keyObserver] objectForKey:AppIDKey]];
    NSString *theAppKey = [userDefaults objectForKey:[[self keyObserver] objectForKey:AppKeyKey]];
    NSString *theAppSecret = [userDefaults objectForKey:[[self keyObserver] objectForKey:AppSecretKey]];
    NSString *theRedirectURI = [userDefaults objectForKey:[[self keyObserver] objectForKey:RedirectURIKey]];

    [self setAppID:theAppID];
    [self setAppKey:theAppKey];
    [self setAppSecret:theAppSecret];
    [self setRedirectURI:theRedirectURI];
}

- (void)writeAuthInfo:(id)authInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:[self appID] forKey:[[self keyObserver] objectForKey:AppIDKey]];
    [userDefaults setObject:[self appKey] forKey:[[self keyObserver] objectForKey:AppKeyKey]];
    [userDefaults setObject:[self appSecret] forKey:[[self keyObserver] objectForKey:AppSecretKey]];
    [userDefaults setObject:[self redirectURI] forKey:[[self keyObserver] objectForKey:RedirectURIKey]];
}

- (void)clearAuthInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (NSString *keyName in [[self keyObserver] allKeys]) {
        DLog(@"Remove Key Name : %@", keyName);
        DLog(@"Remove Key : %@", [[self keyObserver] objectForKey:keyName]);
        if ([keyName isEqualToString:AppIDKey] ||
            [keyName isEqualToString:AppKeyKey] ||
            [keyName isEqualToString:AppSecretKey] ||
            [keyName isEqualToString:RedirectURIKey]) {
            continue;
        }
        [userDefaults removeObjectForKey:[[self keyObserver] objectForKey:keyName]];
    }

    [[self keyObserver] removeAllObjects];
}

- (void)registerKey:(NSArray *)definedKeys
{
    for (NSString *definedKey in definedKeys) {
        [[self keyObserver] setValue:[self getKeyName:definedKey] forKey:definedKey];
    }
}

- (NSString *)getKeyName:(NSString *)definedKey
{
    NSString *apiName = [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:@"Connector" withString:@""];
    NSString *keyName = [[apiName capitalizedString] stringByAppendingString:definedKey];
    DLog(@"Key Name => %@", keyName);
    return keyName;
}

#pragma mark Authorization

- (SNSAuthorize *)getSNSAuthorize
{
#ifdef DEBUG
    [NSException raise:NSInternalInconsistencyException format:@"Must override %@ in a subclass", NSStringFromSelector(_cmd)];
#endif
    return nil;
}

- (NSDictionary *)getRequiredParams
{
    return [NSDictionary dictionary];
}

- (NSDictionary *)getRequiredHeader
{
    return [NSDictionary dictionary];
}

- (NSString *)getAPIDomainURL
{
#ifdef DEBUG
    [NSException raise:NSInternalInconsistencyException format:@"Must override %@ in a subclass", NSStringFromSelector(_cmd)];
#endif
    return @"";
}

- (void)prepareAuthorize
{
}

- (void)login
{
    if ([self isLoggedIn]) {
        if ([[self delegate] respondsToSelector:@selector(connectorAlreadyLoggedIn:)]) {
            [[self delegate] connectorAlreadyLoggedIn:self];
        }

        if ([self isUserExclusive]) {
            return;
        }
    }

    if (![self authorize]) {
        [self setAuthorize:[self getSNSAuthorize]];
    }

    [[self authorize] setDelegate:self];

    if ([[self redirectURI] length] > 0) {
        [[self authorize] setRedirectURI:[self redirectURI]];
    } else {
        [[self authorize] setRedirectURI:@"http://"];
    }

    [[self authorize] prepareAuthorize];
}

- (void)loginUsingUserID:(NSString *)theUserID password:(NSString *)thePassword
{
    [self setUserName:theUserID];

    if ([self isLoggedIn])
    {
        if ([[self delegate] respondsToSelector:@selector(connectorAlreadyLoggedIn:)])
        {
            [[self delegate] connectorAlreadyLoggedIn:self];
        }
        if ([self isUserExclusive])
        {
            return;
        }
    }

    SNSAuthorize *auth = [self getSNSAuthorize];
    [auth setDelegate:self];
    self.authorize = auth;
    SNS_RELEASE(auth);

    if ([[self redirectURI] length] > 0)
    {
        [[self authorize] setRedirectURI:[self redirectURI]];
    }
    else
    {
        [[self authorize] setRedirectURI:@"http://"];
    }

    [[self authorize] startAuthorizeUsingUserID:theUserID password:thePassword];
}

- (void)refreshAccessToken
{
    [[self authorize] refreshAccessToken];
}

- (void)logout
{
    // todo some thing
}

- (BOOL)isLoggedIn
{
    return false;
}

- (NSString *)getExpiresInName
{
    return @"expires_in";
}

- (void)getRequestWithMethodName:(NSString *)methodName
{
    [self createRequestWithMethodName:methodName
                           httpMethod:HTTPGetMethod
                               params:nil
                         postDataType:PostDataTypeNormal
                     httpHeaderFields:nil];
}

- (void)getRequestWithMethodName:(NSString *)methodName
                          params:(NSDictionary *)params
{
    [self createRequestWithMethodName:methodName
                           httpMethod:HTTPGetMethod
                               params:params
                         postDataType:PostDataTypeNormal
                     httpHeaderFields:nil];
}

- (void)postRequestWithMethodName:(NSString *)methodName
                           params:(NSDictionary *)params
{
    [self createRequestWithMethodName:methodName
                           httpMethod:HTTPPostMethod
                               params:params
                         postDataType:PostDataTypeNormal
                     httpHeaderFields:nil];
}

- (void)postRequestWithMethodName:(NSString *)methodName
                           params:(NSDictionary *)params
                     postDataType:(PostDataType)postDataType
{
    [self createRequestWithMethodName:methodName
                           httpMethod:HTTPPostMethod
                               params:params
                         postDataType:postDataType
                     httpHeaderFields:nil];
}

- (void)postRequestWithMethodName:(NSString *)methodName
                           params:(NSDictionary *)params
                     postDataType:(PostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    [self createRequestWithMethodName:methodName
                           httpMethod:HTTPPostMethod
                               params:params
                         postDataType:postDataType
                     httpHeaderFields:httpHeaderFields];
}

- (void)postRequestWithParams:(NSDictionary *)params
{
    [self createRequestWithMethodName:@""
                           httpMethod:HTTPPostMethod
                               params:params
                         postDataType:PostDataTypeNormal
                     httpHeaderFields:nil];
}

- (void)postRequestWithParams:(NSDictionary *)params
                 postDataType:(PostDataType)postDataType
{
    [self createRequestWithMethodName:@""
                           httpMethod:HTTPPostMethod
                               params:params
                         postDataType:postDataType
                     httpHeaderFields:nil];
}

- (void)createRequestWithMethodName:(NSString *)methodName
                         httpMethod:(NSString *)httpMethod
                             params:(NSDictionary *)params
                       postDataType:(PostDataType)postDataType
                   httpHeaderFields:(NSDictionary *)httpHeaderFields
{

}

- (void)authorize:(SNSAuthorize *)authorize didSucceedWithAuthInfo:(id)authInfo
{
    [self writeAuthInfo:authInfo];

    if ([[self delegate] respondsToSelector:@selector(connectorDidLogIn:)]) {
        [[self delegate] connectorDidLogIn:self];
    }
}

- (void)authorize:(SNSAuthorize *)authorize didFailWithError:(NSError *)error
{
    if ([[self delegate] respondsToSelector:@selector(connector:didFailToLogInWithError:)]) {
        [[self delegate] connector:self didFailToLogInWithError:error];
    }
}

#pragma mark - SNSRequestDelegate Methods

- (void)request:(SNSRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([[self delegate] respondsToSelector:@selector(connector:requestDidSucceedWithResult:)]) {
        [[self delegate] connector:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(SNSRequest *)request didFailWithError:(NSError *)error
{
    DLog(@"Error Request Message ====> %@", error);
    if ([[self delegate] respondsToSelector:@selector(connector:requestDidFailWithError:)]) {
        [[self delegate] connector:self requestDidFailWithError:error];
    }
}

- (BOOL)is:(NSString *)url
{
    return [[[self request] url] hasPrefix:url];
}

@end
