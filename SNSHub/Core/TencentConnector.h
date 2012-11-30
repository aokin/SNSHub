//
//  TencentEngine.h
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth2Connector.h"

#define NamKey              @"NameKey"
#define NickKey             @"NickKey"
#define OpenIDKey           @"OpenIDKey"

@interface TencentConnector : SNSOAuth2Connector

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *openID;

@end
