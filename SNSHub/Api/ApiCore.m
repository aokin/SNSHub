//
//  ApiCore.m
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "ApiCore.h"

NSString *const CancelOpenIDLoginNotification = @"CancelOpenIDLoginNotification";

NSString *const ResultKey =  @"result";
NSString *const MessageKey = @"MessageKey";
NSString *const MessageTypeKey = @"MessageTypeKey";
NSString *const ErrorCodeKey = @"ErrorCodeKey";
NSString *const ErrorInfoKey = @"ErrorInfoKey";
NSString *const ServiceNameKey = @"ServiceNameKey";

NSString *const ReturnTypeJSON = @"json";
NSString *const ReturnTypeXML = @"xml";


@implementation ApiCore

+ (ApiCore *)shared
{
    static ApiCore *apiCore = nil;
    if (nil == apiCore) {
        apiCore = [[ApiCore alloc] init];
    }
    return apiCore;
}

- (id)init
{
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [_delegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *selectorString = NSStringFromSelector([invocation selector]);
    NSString *loginSelectorString = NSStringFromSelector(@selector(login));
    NSString *refreshSelectorString = NSStringFromSelector(@selector(refreshAccessToken:));
    if ([selectorString isEqualToString:loginSelectorString] ||
        [selectorString isEqualToString:refreshSelectorString]) {
        // TODO Access token expiration 
        if (YES) {
            [invocation invokeWithTarget:_delegate];
        } else {
            [_delegate refreshAccessToken:^(id data) {
                [invocation invokeWithTarget:_delegate];
            }];
        }
    } else {
        [invocation invokeWithTarget:_delegate];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [_delegate respondsToSelector:aSelector];
}

@end
