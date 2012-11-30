//
//  KaixinApi.m
//  SNSHub
//
//  Created by Cameron Ling on 12-2-8.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "KaixinApi.h"
#import "KaixinConnector.h"

#undef APIDomainURL
#define APIDomainURL    @"https://api.kaixin001.com/"

#define RecordsAdd              @"records/add"
#define UsersMe                 @"users/me"

@implementation KaixinApi

DEF_STATIC_PROPERTY3(USERINFO,          APIDomainURL,   [@"users/me" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(SHARE,             APIDomainURL,   [@"records/add" stringByAppendingString:RETURN_JSON_FORMAT])

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    [[self connector] getRequestWithMethodName:KaixinApi.USERINFO];
}

- (void)originMessage:(NSDictionary *)params
{
    [self shareMessage:params];
}

- (void)shareMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    UIImage *image = [params objectForKey:@"image"];
    if (image) {
        [dic setObject:[params objectForKey:@"content"] forKey:@"content"];
        [dic setObject:@"0" forKey:@"save_to_album"];
        [dic setObject:[params objectForKey:@"image"] forKey:@"pic"];
        
        [[self connector] postRequestWithMethodName:KaixinApi.SHARE params:dic postDataType:PostDataTypeMultipart];
    }else {
        [dic setObject:[params objectForKey:@"content"] forKey:@"status"];

        [[self connector] postRequestWithMethodName:KaixinApi.SHARE params:dic];
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
    
    if ([connector is:KaixinApi.USERINFO]) {
        NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [data objectForKey:@"avatar_large"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeKaixin];
            [accountInfo setAccessToken:[(KaixinConnector *)connector accessToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];
            
            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }

            SNS_RELEASE(accountInfo);
        }
    }

    if ([connector is:KaixinApi.SHARE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }
    
    SNS_RELEASE(result);
}

@end
