//
//  KaixinEngine.h
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth2Connector.h"

#define ScopeKey            @"ScopeKey"

@interface KaixinConnector : SNSOAuth2Connector

@property (nonatomic, retain) NSString *scope;

@end
