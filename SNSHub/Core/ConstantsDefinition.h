//
//  ConstantsDefinition.m
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//


#define ErrorDomain           @"ErrorDomain"
#define ErrorCodeKey          @"ErrorCodeKey"

typedef enum
{
	ErrorCodeInterface          = 100,
	ErrorCodeSDK                = 101,

	ErrorCodeParseError         = 200,
	ErrorCodeRequestError       = 201,
	ErrorCodeAccessError        = 202,
	ErrorCodeAuthorizeError     = 203,
} ErrorCode;