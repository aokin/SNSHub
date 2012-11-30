//
//  SNSOAuth2Connector.h
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSConnector.h"

@interface SNSOAuth2Connector : SNSConnector <NSCoding>

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSInteger expiresIn;
@property (nonatomic, retain) NSDate *expiresTime;

- (BOOL)isAuthorizeExpired;

@end
