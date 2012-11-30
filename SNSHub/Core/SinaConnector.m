//
//  SinaEngine.m
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SinaConnector.h"
#import "SinaAuthorize.h"

@implementation SinaConnector

- (void)dealloc
{
    SNS_RELEASE(_uid);
    SNS_RELEASE(_remindTime);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[RemindInKey, RemindTimeKey, UIDKey]];
        [self readAuthInfo];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theUID = [userDefaults objectForKey:[[self keyObserver] objectForKey:UIDKey]];
    NSUInteger theRemindIn = [userDefaults integerForKey:[[self keyObserver] objectForKey:RemindInKey]];
    NSDate *theRemindTime = [userDefaults objectForKey:[[self keyObserver] objectForKey:RemindTimeKey]];
    
    [self setUid:theUID];
    [self setRemindIn:theRemindIn];
    [self setRemindTime:theRemindTime];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];
    
    NSUInteger theRemindIn = [[authInfo objectForKey:@"remind_in"] integerValue];
    NSString *theUID = [authInfo objectForKey:@"uid"];

    [self setUid:theUID];
    [self setRemindIn:theRemindIn];
    [self setRemindTime:[[NSDate date] dateByAddingTimeInterval:theRemindIn]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:[self uid] forKey:[[self keyObserver] objectForKey:UIDKey]];
    [userDefaults setInteger:[self remindIn] forKey:[[self keyObserver] objectForKey:RemindInKey]];
    [userDefaults setObject:[self remindTime] forKey:[[self keyObserver] objectForKey:RemindTimeKey]];
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[SinaAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

@end
