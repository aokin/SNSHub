//
//  DoubanAuthorize.m
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "DoubanAuthorize.h"

@implementation DoubanAuthorize

DEF_AUTHORIZE_URL(@"https://www.douban.com/service/auth2/auth");
DEF_ACCESSTOKEN_URL(@"https://www.douban.com/service/auth2/token");

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"douban_basic_common,shuo_basic_r,shuo_basic_w", @"scope", nil];
}

@end
