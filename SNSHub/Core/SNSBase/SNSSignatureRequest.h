//
//  SNSSignatureRequest.h
//  SNSHub
//
//  Created by William on 12-11-1.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "SNSRequest.h"

@class SNSSignatureRequest;

@protocol SNSSignatureRequestDelegate  <NSObject>

@required

- (NSDictionary *)request:(SNSSignatureRequest *)request willCalculateSignature:(NSDictionary *)params;

@end


@interface SNSSignatureRequest : SNSRequest

@property (nonatomic, assign) BOOL  useOAuth;
@property (nonatomic, retain) id<SNSRequestDelegate, SNSSignatureRequestDelegate> delegate;

@end
