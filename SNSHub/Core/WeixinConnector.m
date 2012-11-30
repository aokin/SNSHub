//
//  WeixinConnector.m
//  SNSHub
//
//  Created by William on 12-11-28.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "WeixinConnector.h"
#import "WeixinAuthorize.h"

@implementation WeixinConnector

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[WeixinAuthorize  alloc] initWithAppKey:[self appKey] appSecret:[self appSecret] appID:[self appID]]);
}


@end
