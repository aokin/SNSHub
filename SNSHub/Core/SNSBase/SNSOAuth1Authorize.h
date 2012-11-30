//
//  SNSOAuth1Authorize.h
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSAuthorize.h"

typedef enum {
    RequestTokenStage,
    AccessTokenStage
} AuthorizeStage;

@interface SNSOAuth1Authorize : SNSAuthorize

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *oauthTokenSecret;

@property (nonatomic, assign) AuthorizeStage authorizeStage;

- (NSString *)getRequestTokenURL;

@end
