//
//  SinaAuthorize.m
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SinaAuthorize.h"

@implementation SinaAuthorize

DEF_AUTHORIZE_URL(@"https://api.weibo.com/oauth2/authorize");
DEF_ACCESSTOKEN_URL(@"https://api.weibo.com/oauth2/access_token");

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"mobile", @"display", nil];
}

@end
