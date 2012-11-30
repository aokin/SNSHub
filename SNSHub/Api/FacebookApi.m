//
//  FacebookApi.m
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "FacebookApi.h"
#import "FacebookConnector.h"
#import "AccountInfo.h"

#define Me                      @"me"
#define kFacebookAPI_Feed      @"me/feed"
#define kFacebookAPI_Photo      @"me/photo"

@implementation FacebookApi

- (void)dealloc
{
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (NSString *)userInfoMethod
{
    return Me;
}

- (void)connectorDidLogIn:(SNSConnector *)connector
{
    NSLog(@"User login successful.");
    NSMutableDictionary *params = SNS_AUTORELEASE([[NSMutableDictionary alloc] init]);
    
    [params setObject:@"name,picture" forKey:@"fields"];
    [[self connector] getRequestWithMethodName:[self userInfoMethod] params:params];
}

#pragma mark - ApiCoreDelegate
- (void)originMessage:(NSDictionary *)params
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    UIImage *image = [params objectForKey:@"image"];
    if (image) {
        [dic setObject:[params objectForKey:@"content"] forKey:@"name"];
        [dic setObject:[params objectForKey:@"image"] forKey:@"image"];
        NSString *methodName = [(NSString *)kFacebookAPI_Photo stringByAppendingString:RETURN_JSON_FORMAT];
        
        [[self connector] postRequestWithMethodName:methodName params:dic postDataType:PostDataTypeMultipart];
    }else {
        [dic setObject:[params objectForKey:@"content"] forKey:@"message"];
        NSString *methodName = [(NSString *)kFacebookAPI_Feed stringByAppendingString:RETURN_JSON_FORMAT];
        
        [[self connector] postRequestWithMethodName:methodName params:dic];
    }
    SNS_RELEASE(dic);
}

- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)data
{
    NSString *lastURL = [[connector request] url];
    
    NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
    NSString *message = [data objectForKey:@"error"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:errorCode == 0 ? [NSNumber numberWithInteger:ResultSuccess] : [NSNumber numberWithInteger:ResultFail] forKey:ResultKey];
    [result setValue:[NSNumber numberWithInteger:errorCode] forKey:ErrorCodeKey];
    [result setValue:message forKey:MessageKey];
    
    if ([lastURL hasSuffix:[self userInfoMethod]]) {
        NSString *uid = [data objectForKey:@"id"];
        NSString *uName = [data objectForKey:@"name"];
        NSString *imageUrl = [[[data objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        if ([uid length] > 0) {
            AccountInfo *accountInfo = [[AccountInfo alloc] initWithAccountId:uid
                                                           andOpenAccountName:uName
                                                       andOpenAccountImageUrl:imageUrl
                                                               andAccountType:SNSTypeFacebook];
            [accountInfo setAccessToken:[(FacebookConnector *)connector accessToken]];
            [accountInfo setAccountInfo:data];
            [self setAccountInfo:accountInfo];
            
            if ([self delegate] && [(NSObject *)[self delegate] respondsToSelector:@selector(didLogin:)]) {
                [[self delegate] didLogin:accountInfo];
            }
            SNS_RELEASE(accountInfo);
        }
    }
    SNS_RELEASE(result);
}
@end
