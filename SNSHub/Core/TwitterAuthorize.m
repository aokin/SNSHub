//
//  TwitterAuthorize.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "TwitterAuthorize.h"
#import "CategoryUtil.h"

#define TwitterRequestTokenURL          @"https://api.twitter.com/oauth/request_token"
#define TwitterAuthorizeURL             @"https://api.twitter.com/oauth/authenticate"
#define TwitterAccessTokenURL           @"https://api.twitter.com/oauth/access_token"

@implementation TwitterAuthorize

- (NSString *)getRequestTokenURL
{
    return TwitterRequestTokenURL;
}

- (NSString *)getAuthorizeBaseURL
{
    return TwitterAuthorizeURL;
}

- (NSString *)getAccessTokenBaseURL
{
    return TwitterAccessTokenURL;
}

- (NSDictionary *)addAuthorizeParams
{
    NSString *timestamp = [NSString stringWithFormat:@"%d", [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue]];

    return [NSDictionary dictionaryWithObjectsAndKeys:@"HMAC-SHA1", @"oauth_signature_method", @"1.0", @"oauth_version", [self appKey], @"oauth_consumer_key", [[NSString GUIDString] base64EncodedString], @"oauth_nonce", timestamp, @"oauth_timestamp", nil];
}

@end
