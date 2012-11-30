//
//  SNSAuthorize.h
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SNSRequest.h"
#import "SNSAuthorizeWebView.h"

#undef	DEF_AUTHORIZE_URL
#define DEF_AUTHORIZE_URL(__url) \
		- (NSString *)getAuthorizeBaseURL \
		{ \
			return __url; \
		}

#undef	DEF_ACCESSTOKEN_URL
#define DEF_ACCESSTOKEN_URL(__url) \
		- (NSString *)getAccessTokenBaseURL \
		{ \
			return __url; \
		}

@class SNSAuthorize;

@protocol SNSAuthorizeDelegate <NSObject>

@required

- (void)authorize:(SNSAuthorize *)authorize didSucceedWithAuthInfo:(id)authInfo;
- (void)authorize:(SNSAuthorize *)authorize didFailWithError:(NSError *)error;

@end

@interface SNSAuthorize : NSObject <SNSAuthorizeWebViewDelegate, SNSRequestDelegate> 

@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;

@property (nonatomic, retain) SNSRequest *request;
@property (nonatomic, retain) id<SNSAuthorizeDelegate> delegate;

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;
- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret appID:(NSString *)theAppID;

- (void)prepareAuthorize;
- (void)startAuthorize;
- (void)startAuthorize:(NSDictionary *)sendParams;
- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password;
- (void)refreshAccessToken;

- (NSString *)getAuthorizeBaseURL;
- (NSString *)getAccessTokenBaseURL;
- (NSDictionary *)addAuthorizeParams;
- (NSString *)getRefreshAccessTokenHttpMethod;

@end
