//
//  RenrenApi.m
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-31.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "RenrenApi.h"
#import "AccountInfo.h"
#import "RenrenConnector.h"

#undef APIDomainURL
#define APIDomainURL    @"http://api.renren.com/restserver.do/"

@implementation RenrenApi

DEF_STATIC_PROPERTY3(USERINFO,          @"",   @"users.getInfo")

DEF_STATIC_PROPERTY3(SHARE,             @"",   @"share.share")
DEF_STATIC_PROPERTY3(SHARE_TO_ALBUM,    @"",   @"photos.upload")


- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    NSMutableDictionary *params = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [params setObject:RenrenApi.USERINFO forKey:@"method"];

    [[self connector] postRequestWithMethodName:APIDomainURL params:params];
}

- (void)uploadImage:(NSDictionary *)params
{
    NSMutableDictionary *sendParams = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [sendParams setObject:RenrenApi.SHARE_TO_ALBUM forKey:@"method"];
    [sendParams setObject:[params objectForKey:@"image"] forKey:@"upload"];
    
    [[self connector] postRequestWithMethodName:APIDomainURL params:sendParams postDataType:PostDataTypeMultipart];
    [self setLastParams:params];
}

- (void)originMessage:(NSDictionary *)params
{
    NSString *content = [params objectForKey:@"content"];
    
    NSMutableDictionary *sentParams = [[[NSMutableDictionary alloc] init] autorelease];
    
    [sentParams setObject:content forKey:@"comment"];
    [sentParams setObject:RenrenApi.SHARE forKey:@"method"];
    [sentParams setObject:@"http://www.pizzahut.com.cn/" forKey:@"url"];
    [sentParams setObject:@"6" forKey:@"type"];
}

- (void)shareContent:(NSDictionary *)params
{
    NSMutableDictionary *sendParams = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [sendParams setObject:[params objectForKey:@"content"] forKey:@"comment"];
    [sendParams setObject:[params objectForKey:@"ugc_id"] forKey:@"ugc_id"];
    [sendParams setObject:[params objectForKey:@"user_id"] forKey:@"user_id"];
    [sendParams setObject:RenrenApi.SHARE forKey:@"method"];
    [sendParams setObject:@"2" forKey:@"type"];

    [[self connector] postRequestWithMethodName:APIDomainURL params:sendParams];
}

- (void)shareMessage:(NSDictionary *)params
{    
    [self uploadImage:params];
}

#pragma mark - ApiCoreDelegate

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    if ([data isKindOfClass:[NSArray class]]) {
        data = [data objectAtIndex:0];
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
    NSString *message = [data objectForKey:@"error"];
    
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];
    
    if ([connector is:RenrenApi.USERINFO]) {
        NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [data objectForKey:@"avatar_large"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeRenren];
            [accountInfo setAccessToken:[(RenrenConnector *)connector accessToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];
            
            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }

            SNS_RELEASE(accountInfo);
        }
    }

    if ([connector is:RenrenApi.SHARE_TO_ALBUM]) {
        NSMutableDictionary *params = SNS_AUTORELEASE([@{} mutableCopy]);
        [params setValue:[[self lastParams] objectForKey:@"content"] forKey:@"content"];
        [params setValue:[NSString stringWithFormat:@"%qi", [(NSNumber *)[data objectForKey:@"pid"] longLongValue]] forKey:@"ugc_id"];
        [params setValue:[NSString stringWithFormat:@"%d", [(NSNumber *)[data objectForKey:@"uid"] integerValue]] forKey:@"user_id"];
        
        [self shareContent:params];
    }

    if ([connector is:RenrenApi.SHARE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }
    
    SNS_RELEASE(result);
}

@end
