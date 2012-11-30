//
//  LinkdinAuthorize.m
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "LinkedinAuthorize.h"

#define LinkedinAuthorizeURL        @"https://api.weibo.com/oauth2/authorize"
#define LinkedinAccessTokenURL      @"https://api.weibo.com/oauth2/access_token"

@implementation LinkedinAuthorize

- (NSString *)getAuthorizeBaseURL
{
    return LinkedinAuthorizeURL;
}

- (NSString *)getAccessTokenBaseURL
{
    return LinkedinAccessTokenURL;
}

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"mobile", @"display", nil];
}

@end
