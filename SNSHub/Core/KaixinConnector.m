//
//  KaixinEngine.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "KaixinConnector.h"
#import "KaixinAuthorize.h"

@implementation KaixinConnector

- (void)dealloc
{
    SNS_RELEASE(_scope);

#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[ScopeKey]];
        [self readAuthInfo];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *theScope = [userDefaults objectForKey:[[self keyObserver] objectForKey:ScopeKey]];

    [self setScope:theScope];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];

    NSString *theScope = [authInfo objectForKey:@"scope"];
    
    [self setScope:theScope];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:[self scope] forKey:[[self keyObserver] objectForKey:ScopeKey]];
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[KaixinAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

@end
