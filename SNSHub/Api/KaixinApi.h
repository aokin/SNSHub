//
//  KaixinApi.h
//  SNSHub
//
//  Created by Cameron Ling on 12-2-8.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCore.h"
#import "BaseApi.h"

@interface KaixinApi : BaseApi <SNSConnectorDelegate, ApiCoreDelegate>

AS_STATIC_PROPERTY(USERINFO)

AS_STATIC_PROPERTY(SHARE)

@end
