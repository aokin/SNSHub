//
//  FacebookEngine.m
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "FacebookConnector.h"
#import "FacebookAuthorize.h"

#define FacebookAPIDomainURL     @"https://graph.facebook.com/"

@implementation FacebookConnector

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[FacebookAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

- (NSString *)getAPIDomainURL
{
    return FacebookAPIDomainURL;
}

#pragma mark override
- (NSString *)getExpiresInName
{
    return @"expires";
}

@end
