//
//  SNSOAuth1Connector.h
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSConnector.h"

#define RequestTokenKey                 @"RequestTokenKey"
#define RequestTokenSecretKey           @"RequestTokenSecretKey"
#define OAuthCallbackConfirmedKey       @"OAuthCallbackConfirmedKey"

#define OAuthTokenKey                   @"OAuthTokenKey"
#define OAuthTokenSecretKey             @"OAuthTokenSecretKey"

@interface SNSOAuth1Connector : SNSConnector

@property (nonatomic, retain) NSString *requestToken;
@property (nonatomic, retain) NSString *requestTokenSecret;
@property (nonatomic, assign) BOOL oauthCallbackConfirmed;

@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *oauthTokenSecret;

@property (nonatomic, assign) BOOL parameterExcludeSignature;

@end
