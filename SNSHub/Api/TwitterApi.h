//
//  TwitterApi.h
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCore.h"
#import "BaseApi.h"

@interface TwitterApi : BaseApi <SNSConnectorDelegate, ApiCoreDelegate>

AS_STATIC_PROPERTY(USERINFO)

AS_STATIC_PROPERTY(SHARE)
AS_STATIC_PROPERTY(SHARE_WITH_FILE)

@end
