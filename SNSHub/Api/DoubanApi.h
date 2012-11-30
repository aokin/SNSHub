//
//  DoubanApi.h
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCore.h"
#import "BaseApi.h"

@interface DoubanApi : BaseApi <SNSConnectorDelegate, ApiCoreDelegate>

AS_STATIC_PROPERTY(USERINFO);
AS_STATIC_PROPERTY(SHARE);

@end
