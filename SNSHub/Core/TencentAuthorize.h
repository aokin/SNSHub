//
//  TencentAuthorize.h
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSAuthorize.h"

@interface TencentAuthorize : SNSAuthorize <SNSAuthorizeWebViewDelegate>

@property (nonatomic, strong) NSString  *openID;
@property (nonatomic, strong) NSString  *openKey;

@end
