//
//  SinaEngine.h
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth2Connector.h"

#define RemindInKey             @"RemindInKey"
#define RemindTimeKey           @"RemindTimeKey"
#define UIDKey                  @"UIDKey"

@interface SinaConnector : SNSOAuth2Connector <NSCoding>

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSDate *remindTime;
@property (nonatomic, assign) NSUInteger remindIn;

@end
