//
//  TencentConnector.m
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TencentConnector.h"
#import "TencentAuthorize.h"

#define TencentAPIDomainURL     @"https://open.t.qq.com/api/"

@implementation TencentConnector

- (void)dealloc
{
    SNS_RELEASE(_name);
    SNS_RELEASE(_nick);
    SNS_RELEASE(_openID);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[NamKey, NickKey, OpenIDKey]];
        [self readAuthInfo];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theName = [userDefaults objectForKey:[[self keyObserver] objectForKey:NamKey]];
    NSString *theNick = [userDefaults objectForKey:[[self keyObserver] objectForKey:NickKey]];
    NSString *theOpenID = [userDefaults objectForKey:[[self keyObserver] objectForKey:OpenIDKey]];
    
    [self setName:theName];
    [self setNick:theNick];
    [self setOpenID:theOpenID];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];
    
    NSString *theName = [authInfo objectForKey:@"name"];
    NSString *theNick = [authInfo objectForKey:@"nick"];
    
    [self setName:theName];
    [self setNick:theNick];
    [self setOpenID:[(TencentAuthorize *)[self authorize] openID]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[self name] forKey:[[self keyObserver] objectForKey:NamKey]];
    [userDefaults setObject:[self nick] forKey:[[self keyObserver] objectForKey:NickKey]];
    [userDefaults setObject:[self openID] forKey:[[self keyObserver] objectForKey:OpenIDKey]];
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[TencentAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

- (NSDictionary *)getRequiredParams
{
    NSDictionary *requiredParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self appKey], @"oauth_consumer_key",
                                    [self openID], @"openid",
                                    [self appKey], @"clientip",
                                    @"2.a", @"oauth_version",
                                    @"json", @"format",
                                    @"all", @"scope", nil];
    
    return requiredParams;
}

- (NSString *)getAPIDomainURL
{
    return TencentAPIDomainURL;
}

- (void)request:(SNSRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([[self delegate] respondsToSelector:@selector(connector:requestDidSucceedWithResult:)]) {
        [[self delegate] connector:self requestDidSucceedWithResult:[result objectForKey:@"data"]];
    }
}

@end
