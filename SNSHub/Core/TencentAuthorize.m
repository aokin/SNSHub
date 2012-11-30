//
//  TencentAuthorize.m
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TencentAuthorize.h"
#import "CategoryUtil.h"

@implementation TencentAuthorize

DEF_AUTHORIZE_URL(@"https://open.t.qq.com/cgi-bin/oauth2/authorize");
DEF_ACCESSTOKEN_URL(@"https://open.t.qq.com/cgi-bin/oauth2/access_token");

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type",/* @"ios", @"appfrom", @"2", @"wap",*/ nil];
}

- (void)authorizeWebView:(SNSAuthorizeWebView *)webView didReceiveAuthorizeInfo:(id)authorizeInfo
{
    [self setOpenID:[authorizeInfo objectForKey:@"openid"]];
    [self setOpenKey:[authorizeInfo objectForKey:@"openkey"]];
    
    [super authorizeWebView:webView didReceiveAuthorizeInfo:authorizeInfo];
}

- (NSString *)getRefreshAccessTokenHttpMethod
{
    return HTTPGetMethod;
}

@end
