//
//  WeixinAuthorize.m
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "WeixinAuthorize.h"


@implementation WeixinAuthorize

DEF_AUTHORIZE_URL(@"https://open.weixin.qq.com/oauth");
DEF_ACCESSTOKEN_URL(@"https://api.weixin.qq.com/token"/* TODO */);

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[self appId], @"appid", nil];
    [[self request] disconnect];
    
    self.request = [SNSRequest requestWithURL:[self getAccessTokenBaseURL]
                                   httpMethod:[self getRefreshAccessTokenHttpMethod]
                                       params:params
                                 postDataType:PostDataTypeNormal
                             httpHeaderFields:nil
                                     delegate:self];
    
    [[self request] connect];
}

- (void)prepareAuthorize
{
    [self startAuthorize:[NSDictionary dictionaryWithObjectsAndKeys:[self appId], @"appid", nil]];
}

- (NSDictionary *)addAuthorizeParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", nil];
}

@end
