//
//  DoubanConnect.h
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth2Connector.h"

#define DoubanUserIDKey             @"DoubanUserIDKey"

@interface DoubanConnector : SNSOAuth2Connector

@property (nonatomic, retain) NSString *doubanUserID;

@end
