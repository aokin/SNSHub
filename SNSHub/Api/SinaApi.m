//
//  SinaApi.m
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SinaApi.h"
#import "SinaConnector.h"

#undef APIDomainURL
#define APIDomainURL            @"https://api.weibo.com/2/"

@implementation SinaApi

DEF_STATIC_PROPERTY3(LOGOUT,            APIDomainURL,   [@"account/end_session" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(USERINFO,          APIDomainURL,   [@"users/show" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(SHARE,             APIDomainURL,   [@"statuses/update" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(REPOST,            APIDomainURL,   [@"statuses/repost" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(TIMELINE,          APIDomainURL,   [@"statuses/user_timeline" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(SHARE_WITH_FILE,   APIDomainURL,   [@"statuses/upload" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(COMMENT,           APIDomainURL,   [@"comments/create" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(FOLLOW,            APIDomainURL,   [@"friendships/create" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(FOLLOWED,          APIDomainURL,   [@"friendships/friends/ids" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(IS_FOLLOW,         APIDomainURL,   [@"friendships/show" stringByAppendingString:RETURN_JSON_FORMAT])

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    NSMutableDictionary *params = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [params setObject:[(SinaConnector *)[self connector] uid] forKey:@"uid"];
    
    [[self connector] getRequestWithMethodName:SinaApi.USERINFO params:params];
}

- (void)originMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);

    [dic setObject:[params objectForKey:@"content"] forKey:@"status"];
    UIImage *image = [params objectForKey:@"image"];
    if (image) {
        [dic setObject:image forKey:@"pic"];
        [[self connector] postRequestWithMethodName:SinaApi.SHARE_WITH_FILE params:dic postDataType:PostDataTypeMultipart];
    } else {
        [[self connector] postRequestWithMethodName:SinaApi.SHARE params:dic];
    }
}

- (void)commentMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] initWithCapacity:0]);
    
    NSString *weiboId = [NSString stringWithFormat:@"%@", [params objectForKey:@"id"]];
    [dic setObject:weiboId forKey:@"id"];
    [dic setObject:[params objectForKey:@"content"] forKey:@"comment"];
    
    [[self connector] postRequestWithMethodName:SinaApi.COMMENT params:dic];
}

- (void)resendMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    NSString *weiboId = [NSString stringWithFormat:@"%@", [params objectForKey:@"id"]];
    [dic setObject:weiboId forKey:@"id"];
    [dic setObject:[params objectForKey:@"content"] forKey:@"status"];

    [[self connector] postRequestWithMethodName:SinaApi.REPOST params:dic];
}

- (void)shareMessage:(NSDictionary *)params
{
    [self originMessage:params];
}

- (void)isFollow:(NSDictionary *)params
{
    NSString *source_id =  [[self connector] userName];
    NSString *target_id = [params objectForKey:@"target_id"];
    
    NSMutableDictionary *newParams = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [newParams setObject:target_id forKey:@"target_id"];
    [newParams setObject:source_id forKey:@"source_id"];
    
    [[self connector] getRequestWithMethodName:SinaApi.IS_FOLLOW params:newParams];
}

- (void)follow:(NSDictionary *)params
{
    NSString *uid = [params objectForKey:@"uid"];
    NSMutableDictionary *newParams =  SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [newParams setObject:uid forKey:@"uid"];
    
    [[self connector] postRequestWithMethodName:SinaApi.FOLLOW params:newParams];
}

- (void)getFollowIds
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [(SNSOAuth2Connector *)[self connector] accessToken], @"access_token",
                                       [(SinaConnector *)[self connector] uid], @"id",
                                       nil];
    
    [[self connector] postRequestWithMethodName:SinaApi.FOLLOWED params:params];
}

- (void)getContents:(NSMutableDictionary *)paramsDic
{
    [[self connector] getRequestWithMethodName:SinaApi.TIMELINE params:paramsDic];
}

#pragma mark - SNSRequestDelegate

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
    NSString *message = [data objectForKey:@"error"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];

    if ([connector is:SinaApi.LOGOUT]) {
        if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(didLogout)]) {
            [self.delegate didLogout];
        }
    }

    if ([connector is:SinaApi.USERINFO]) {
        NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [data objectForKey:@"avatar_large"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeSina];
            [accountInfo setAccessToken:[(SinaConnector *)connector accessToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];
            
            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }
            
            SNS_RELEASE(accountInfo);
        }
    }

    if ([connector is:SinaApi.IS_FOLLOW]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didIsFollow:)]) {
            id target = [data objectForKey:@"target"];
            BOOL followed = [(NSNumber *)[target objectForKey:@"followed_by"] integerValue];
            [result setValue:followed ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
            [[self delegate] didIsFollow:result];
        }
    }

    if ([connector is:SinaApi.FOLLOW]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didFollow:)]) {
            NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
            if (uid){
                [[self delegate] didFollow:result];
            }
        }
    }

    if ([connector is:SinaApi.COMMENT]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:COMMENT] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:SinaApi.REPOST]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:RESEND] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:SinaApi.SHARE_WITH_FILE] || [connector is:SinaApi.SHARE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }

    if ([connector is:SinaApi.TIMELINE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didGetContents:)]) {
            [[self delegate] didGetContents:data];
        }
    }
    
    SNS_RELEASE(result);
}

@end
