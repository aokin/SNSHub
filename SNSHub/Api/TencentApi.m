//
//  TencentApi.m
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TencentApi.h"
#import "AccountInfo.h"
#import "TencentConnector.h"

#undef APIDomainURL
#define APIDomainURL     @"https://open.t.qq.com/api/"

@implementation TencentApi

DEF_STATIC_PROPERTY3(USERINFO,          APIDomainURL,   @"user/info")

DEF_STATIC_PROPERTY3(SHARE,             APIDomainURL,   @"t/add")
DEF_STATIC_PROPERTY3(REPOST,            APIDomainURL,   @"t/re_add")
DEF_STATIC_PROPERTY3(TIMELINE,          APIDomainURL,   @"statuses/user_timeline")
DEF_STATIC_PROPERTY3(SHARE_WITH_FILE,   APIDomainURL,   @"t/add_pic")

DEF_STATIC_PROPERTY3(COMMENT,           APIDomainURL,   @"t/comment")

DEF_STATIC_PROPERTY3(FOLLOW,            APIDomainURL,   @"friends/add")
DEF_STATIC_PROPERTY3(IS_FOLLOW,         APIDomainURL,   @"friends/check")

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    [[self connector] getRequestWithMethodName:TencentApi.USERINFO];
}

#pragma mark - ApiCoreDelegate
- (void)isFollow:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [dic setObject:@"1" forKey:@"flag"];
    [dic setObject:[params objectForKey:@"target_id"] forKey:@"fopenids"];
    
    [[self connector] postRequestWithMethodName:TencentApi.IS_FOLLOW params:dic];
}

- (void)follow:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [dic setObject:[params objectForKey:@"uid"] forKey:@"fopenids"];
    
    [[self connector] postRequestWithMethodName:TencentApi.FOLLOW params:dic];
}

- (void)getContents:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [dic setObject:[params objectForKey:@"pageflag"] forKey:@"pageflag"];
    [dic setObject:[params objectForKey:@"timestamp"] forKey:@"timestamp"];
    [dic setObject:[params objectForKey:@"reqnum"] forKey:@"reqnum"];
    [dic setObject:[params objectForKey:@"lastid"] forKey:@"lastid"];
    [dic setObject:[params objectForKey:@"name"] forKey:@"name"];
    
    [[self connector] postRequestWithMethodName:TencentApi.TIMELINE params:dic];
}

- (void)originMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [dic setObject:@"1" forKey:@"syncflag"];
    [dic setObject:[params objectForKey:@"content"] forKey:@"content"];
    UIImage *image = [params objectForKey:@"image"];
    
    if (image) {
        [dic setObject:image forKey:@"pic"];
        
        [[self connector] postRequestWithMethodName:TencentApi.SHARE_WITH_FILE params:dic postDataType:PostDataTypeMultipart];
    } else {
        [[self connector] postRequestWithMethodName:TencentApi.SHARE params:dic];
    }
}

- (void)resendMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [dic setObject:[params objectForKey:@"content"] forKey:@"content"];
    [dic setObject:[params objectForKey:@"id"] forKey:@"reid"];
    
    [[self connector] postRequestWithMethodName:TencentApi.REPOST params:dic];
}

- (void)commentMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [dic setObject:[params objectForKey:@"content"] forKey:@"content"];
    [dic setObject:[params objectForKey:@"id"] forKey:@"reid"];
    
    [[self connector] postRequestWithMethodName:TencentApi.COMMENT params:dic];
}

- (void)shareMessage:(NSDictionary *)params
{
    [self originMessage:params];
}

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    NSInteger errorCode = [[data objectForKey:@"errcode"] integerValue];
    NSString *message = [data objectForKey:@"msg"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];

    NSString *lastURL = [[connector request] url];
    if ([lastURL isEqualToString:TencentApi.USERINFO]) {
        AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:[data objectForKey:@"openid"]
                                                       andOpenAccountName:[data objectForKey:@"name"]
                                                   andOpenAccountImageUrl:[data objectForKey:@"head"]
                                                           andAccountType:SNSTypeTencent];
        [accountInfo setAccessToken:[(TencentConnector *)connector accessToken]];
        [accountInfo setAccountInfo:data];
        [self setAccountInfo:accountInfo];
        
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
            [[self delegate] didLogin:accountInfo];
        }

        SNS_RELEASE(accountInfo);
    }

    if ([connector is:TencentApi.FOLLOW]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didFollow:)]) {
            NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
            if (uid){
                [[self delegate] didFollow:result];
            }
        }
    }

    if ([connector is:TencentApi.COMMENT]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:COMMENT] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:TencentApi.REPOST]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:RESEND] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:TencentApi.SHARE_WITH_FILE] || [connector is:TencentApi.SHARE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:TencentApi.TIMELINE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didGetContents:)]) {
            [[self delegate] didGetContents:data];
        }
    }

    SNS_RELEASE(result);
}

@end
