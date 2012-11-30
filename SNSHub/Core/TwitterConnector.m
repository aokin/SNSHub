//
//  TwitterEngine.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TwitterConnector.h"
#import "TwitterAuthorize.h"

@implementation TwitterConnector

- (void)dealloc
{
    SNS_RELEASE(_screenName);
    SNS_RELEASE(_userID);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[ScreenNameKey, UserIDKey]];
        [self readAuthInfo];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theScreenName = [userDefaults objectForKey:[[self keyObserver] objectForKey:ScreenNameKey]];
    NSString *theUserID = [userDefaults objectForKey:[[self keyObserver] objectForKey:UserIDKey]];
    
    [self setScreenName:theScreenName];
    [self setUserID:theUserID];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];
    
    if ([(SNSOAuth1Authorize *)[self authorize] authorizeStage] == AccessTokenStage) {
        NSString *theScreenName = [authInfo objectForKey:@"screen_name"];
        NSString *theUserID = [authInfo objectForKey:@"user_id"];
        
        [self setScreenName:theScreenName];
        [self setUserID:theUserID];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:[self screenName] forKey:[[self keyObserver] objectForKey:ScreenNameKey]];
        [userDefaults setObject:[self userID]forKey:[[self keyObserver] objectForKey:UserIDKey]];
    }
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[TwitterAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

- (NSDictionary *)getRequiredHeader
{
    NSMutableDictionary *authorizeParams = [NSMutableDictionary dictionaryWithDictionary:[[self authorize] addAuthorizeParams]];
    if ([self oauthToken]) {
        [authorizeParams setValue:[self oauthToken] forKey:@"oauth_token"];
    }
    return authorizeParams;
}

@end
