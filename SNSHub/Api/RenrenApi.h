//
//  RenrenApi.h
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-31.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCore.h"
#import "BaseApi.h"

@interface RenrenApi : BaseApi <SNSConnectorDelegate, ApiCoreDelegate>

AS_STATIC_PROPERTY(USERINFO)

AS_STATIC_PROPERTY(SHARE)
AS_STATIC_PROPERTY(SHARE_TO_ALBUM)

@end
