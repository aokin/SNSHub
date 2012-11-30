//
//  SNSAuthorize.m
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSAuthorize.h"
#import "SNSRequest.h"
#import "ConstantsDefinition.h"
#import "CategoryUtil.h"

@interface SNSAuthorize (Private)

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password;

@end

@implementation SNSAuthorize

- (void)dealloc
{
    SNS_RELEASE(_appId);
    SNS_RELEASE(_appKey);
    SNS_RELEASE(_appSecret);
    SNS_RELEASE(_redirectURI);
    
    [_request setDelegate:nil];
    [_request disconnect];
    SNS_RELEASE(_request);
    
    SNS_RELEASE(_delegate);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

#pragma mark - SNSAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appId = @"";
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret appID:(NSString *)theAppID
{
    if (self = [super init])
    {
        self.appId = theAppID;
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

#pragma mark - SNSAuthorize Private Methods

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self appKey], @"client_id",
                            [self appSecret], @"client_secret",
                            @"authorization_code", @"grant_type",
                            [self redirectURI], @"redirect_uri",
                            code, @"code", nil];
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getAccessTokenBaseURL]
                                   httpMethod:[self getRefreshAccessTokenHttpMethod]
                                       params:params
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:nil
                                     delegate:self];
    
    [[self request] connect];
}

- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self appKey], @"client_id",
                            [self appSecret], @"client_secret",
                            @"password", @"grant_type",
                            [self redirectURI], @"redirect_uri",
                            userID, @"username",
                            password, @"password", nil];
    
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getAccessTokenBaseURL]
                                   httpMethod:HTTPPostMethod
                                       params:params
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:nil
                                     delegate:self];
    
    [[self request] connect];
}

- (NSString *)getAuthorizeBaseURL
{
#ifdef DEBUG
    [NSException raise:NSInternalInconsistencyException format:@"Must override %@ in a subclass", NSStringFromSelector(_cmd)];
#endif
    return @"";
}

- (NSString *)getAccessTokenBaseURL
{
#ifdef DEBUG
    [NSException raise:NSInternalInconsistencyException format:@"Must override %@ in a subclass", NSStringFromSelector(_cmd)];
#endif
    return @"";
}

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionary];
}

- (NSString *)getRefreshAccessTokenHttpMethod
{
    return HTTPPostMethod;
}

- (void)refreshAccessToken
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self appKey], @"client_id",
                            [self appSecret], @"client_secret",
                            @"refresh_token", @"grant_type", nil];
    
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getRefreshAccessTokenHttpMethod]
                                   httpMethod:HTTPPostMethod
                                       params:params
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:nil
                                     delegate:self];
    
    [[self request] connect];
}

#pragma mark - SNSAuthorize Public Methods

- (void)prepareAuthorize
{
    [self startAuthorize];
}

- (void)startAuthorize
{
    NSMutableDictionary *params = SNS_AUTORELEASE([@{} mutableCopy]);
    
    [params setValue:[self appKey] forKey:@"client_id"];
    [params setValue:[self redirectURI] forKey:@"redirect_uri"];
    [params addEntriesFromDictionary:[self addAuthorizeParams]];
    
    NSString *urlString = [SNSRequest serializeURL:[self getAuthorizeBaseURL]
                                            params:params
                                        httpMethod:HTTPGetMethod];
    
    SNSAuthorizeWebView *webView = [[SNSAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
    SNS_RELEASE(webView);
}

- (void)startAuthorize:(NSDictionary *)sendParams
{
    NSMutableDictionary *params = SNS_AUTORELEASE([@{} mutableCopy]);

    [params addEntriesFromDictionary:sendParams];
    [params addEntriesFromDictionary:[self addAuthorizeParams]];
    
    NSString *urlString = [SNSRequest serializeURL:[self getAuthorizeBaseURL]
                                            params:params
                                        httpMethod:HTTPGetMethod];
    
    SNSAuthorizeWebView *webView = [[SNSAuthorizeWebView alloc] init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    [webView show:YES];
    SNS_RELEASE(webView);
}

- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    [self requestAccessTokenWithUserID:userID password:password];
}

#pragma mark - SNSAuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(SNSAuthorizeWebView *)webView didReceiveAuthorizeInfo:(id)authorizeInfo
{
    [webView hide:YES];
    
    NSString *verifyCode = [authorizeInfo objectForKey:@"code"];

    if (![verifyCode isEmpty]) {
        [self requestAccessTokenWithAuthorizeCode:verifyCode];
    }
}

#pragma mark - SNSRequestDelegate Methods

- (void)request:(SNSRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    
    DLog(@"Access Token Info ======> %@", result);
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dict = (NSDictionary *)result;
        
        NSString *token = [dict objectForKey:@"access_token"];
        NSString *userID = [dict objectForKey:@"uid"];
        
        if (!userID) {
            userID = [dict objectForKey:@"name"];
        }
        
        success = token && true;
        
        if (success && [[self delegate] respondsToSelector:@selector(authorize:didSucceedWithAuthInfo:)]) {
            [[self delegate] authorize:self didSucceedWithAuthInfo:result];
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

- (void)request:(SNSRequest *)theReqest didFailWithError:(NSError *)error
{
    if ([[self delegate] respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [[self delegate] authorize:self didFailWithError:error];
    }
}

@end
