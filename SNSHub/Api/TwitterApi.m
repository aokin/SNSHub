//
//  TwitterApi.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TwitterApi.h"
#import "AccountInfo.h"
#import "TwitterConnector.h"

#undef APIDomainURL
#define APIDomainURL    @"https://api.twitter.com/1.1/"

@implementation TwitterApi

DEF_STATIC_PROPERTY3(USERINFO,          APIDomainURL,   [@"users/show" stringByAppendingString:RETURN_JSON_FORMAT])

DEF_STATIC_PROPERTY3(SHARE,             APIDomainURL,   [@"statuses/update" stringByAppendingString:RETURN_JSON_FORMAT])
DEF_STATIC_PROPERTY3(SHARE_WITH_FILE,   APIDomainURL,   [@"statuses/update_with_media" stringByAppendingString:RETURN_JSON_FORMAT])

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    NSMutableDictionary *params = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [params setObject:[(TwitterConnector *)[self connector] userID] forKey:@"user_id"];
    
    [[self connector] getRequestWithMethodName:TwitterApi.USERINFO params:params];
}

- (void)shareMessage:(NSDictionary *)params
{
    NSString *content = [params objectForKey:@"content"];

    NSMutableDictionary *sentParams = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    [sentParams setObject:content forKey:@"status"];

    UIImage *image = [params objectForKey:@"image"];
    if (image) {
        [sentParams setObject:image forKey:@"media[]"];
        
        [(TwitterConnector *)[self connector] setParameterExcludeSignature:YES];
        [[self connector] postRequestWithMethodName:TwitterApi.SHARE_WITH_FILE params:sentParams postDataType:PostDataTypeMultipart];
    } else {
        [[self connector] postRequestWithMethodName:TwitterApi.SHARE params:sentParams];
    }
    
}

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
    NSString *message = [data objectForKey:@"error"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];
    
    if ([connector is:TwitterApi.USERINFO]) {
        NSString *uid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [data objectForKey:@"profile_image_url"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeTwitter];
            [accountInfo setAccessToken:[(TwitterConnector *)connector oauthToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];
            
            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }

            SNS_RELEASE(accountInfo);
        }
    }

    if ([connector is:TwitterApi.SHARE] || [connector is:TwitterApi.SHARE_WITH_FILE]) {
        if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didPostMessage:)]) {
            [result setValue:[NSNumber numberWithInteger:SHARE] forKey:MessageTypeKey];
            [[self delegate] didPostMessage:result];
        }
    }
    
    SNS_RELEASE(result);
}

@end
