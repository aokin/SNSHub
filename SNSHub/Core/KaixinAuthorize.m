//
//  KaixinAuthorize.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "KaixinAuthorize.h"

@implementation KaixinAuthorize

DEF_AUTHORIZE_URL(@"https://api.kaixin001.com/oauth2/authorize");
DEF_ACCESSTOKEN_URL(@"https://api.kaixin001.com/oauth2/access_token");

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", @"1", @"oauth_client", @"1", @"forcelogin", @"basic upload_photo create_records", @"scope", nil];
}

@end
