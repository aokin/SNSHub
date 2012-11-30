//
//  DoubanConnect.m
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "DoubanConnector.h"
#import "DoubanAuthorize.h"

@implementation DoubanConnector

- (void)dealloc
{
    SNS_RELEASE(_doubanUserID);

#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[DoubanUserIDKey]];
        [self readAuthInfo];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *theDoubanUserID = [userDefaults objectForKey:[[self keyObserver] objectForKey:DoubanUserIDKey]];

    [self setDoubanUserID:theDoubanUserID];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];

    NSString *theDoubanUserID = [authInfo objectForKey:@"douban_user_id"];
    
    [self setDoubanUserID:theDoubanUserID];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:[self doubanUserID] forKey:[[self keyObserver] objectForKey:DoubanUserIDKey]];
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[DoubanAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

@end
