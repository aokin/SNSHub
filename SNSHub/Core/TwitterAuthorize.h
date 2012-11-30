//
//  TwitterAuthorize.h
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSOAuth1Authorize.h"

@interface TwitterAuthorize : SNSOAuth1Authorize

@property (nonatomic, retain) NSString *requestToken;
@property (nonatomic, retain) NSString *requestTokenVerify;


@end
