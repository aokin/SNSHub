//
//  FacebookAuthorize.m
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "FacebookAuthorize.h"

#define FacebookAuthorizeURL        @"https://graph.facebook.com/oauth/authorize"
#define FacebookTokenURL            @"https://graph.facebook.com/oauth/access_token"

@implementation FacebookAuthorize

- (NSString *)getAuthorizeBaseURL
{
    return FacebookAuthorizeURL;
}

- (NSString *)getAccessTokenBaseURL
{
    return FacebookTokenURL;
}

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"photo_upload publish_actions read_stream share_item status_update user_photos", @"scope", nil];
}

@end

