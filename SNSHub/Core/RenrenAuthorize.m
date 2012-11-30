//
//  RenrenAuthorize.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "RenrenAuthorize.h"

@implementation RenrenAuthorize

DEF_AUTHORIZE_URL(@"https://graph.renren.com/oauth/authorize");
DEF_ACCESSTOKEN_URL(@"https://graph.renren.com/oauth/token");

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"publish_share photo_upload", @"scope", nil];
}

@end
