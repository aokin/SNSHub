//
//  TwitterEngine.h
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth1Connector.h"

#define ScreenNameKey       @"ScreenNameKey"
#define UserIDKey           @"UserIDKey"

@interface TwitterConnector : SNSOAuth1Connector

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *userID;

@end
