//
//  DoubanApi.m
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "DoubanApi.h"
#import "DoubanConnector.h"

#undef APIDomainURL
#define APIDomainURL    @"https://api.douban.com/"

@implementation DoubanApi

DEF_STATIC_PROPERTY3(USERINFO,  APIDomainURL,   @"v2/user/~me")

DEF_STATIC_PROPERTY3(SHARE,     APIDomainURL,   @"shuo/v2/statuses/")

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    [[self connector] getRequestWithMethodName:DoubanApi.USERINFO];
}

- (void)shareMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    UIImage *image = [params objectForKey:@"image"];
    if (image) {
        [dic setObject:[params objectForKey:@"content"] forKey:@"text"];
        [dic setObject:image forKey:@"image"];
        [dic setObject:[[self connector] appKey] forKey:@"source"];

        NSString *authorizeString = [NSString stringWithFormat:@"Bearer %@", [(DoubanConnector *)[self connector] accessToken]];
        NSDictionary *httpHeader = [NSDictionary dictionaryWithObjectsAndKeys:authorizeString, @"Authorization", nil];
        [[self connector] postRequestWithMethodName:DoubanApi.SHARE params:dic postDataType:PostDataTypeMultipart httpHeaderFields:httpHeader];
    }else {
        [dic setObject:[params objectForKey:@"content"] forKey:@"text"];
        [dic setObject:[[self connector] appKey] forKey:@"source"];

        NSString *authorizeString = [NSString stringWithFormat:@"Bearer %@", [(DoubanConnector *)[self connector] accessToken]];
        NSDictionary *httpHeader = [NSDictionary dictionaryWithObjectsAndKeys:authorizeString, @"Authorization", nil];
        [[self connector] postRequestWithMethodName:DoubanApi.SHARE params:dic postDataType:PostDataTypeNormal httpHeaderFields:httpHeader];
    }

    SNS_RELEASE(dic);
}

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
    NSString *message = [data objectForKey:@"error"];

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];

    if ([connector is:DoubanApi.USERINFO]) {
        NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [data objectForKey:@"avatar"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeDouban];
            [accountInfo setAccessToken:[(DoubanConnector *)connector accessToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];

            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }

            SNS_RELEASE(accountInfo);
        }
    }

    if ([connector is:DoubanApi.SHARE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    SNS_RELEASE(result);
}

@end
