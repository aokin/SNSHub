//
//  SNSConnector.h
//  SNSHub
//
//  Created by William on 12-11-2.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSRequest.h"
#import "SNSAuthorize.h"

#define RedirectURI                 @"http://iwinenotesapi.iwine.com/callback"

#define ExpiresInKey                @"ExpiresInKey"
#define ExpiresTimeKey              @"ExpiresTimeKey"
#define AccessTokenKey              @"AccessTokenKey"
#define RefreshTokenKey             @"RefreshTokenKey"

#define UserIDKey                   @"UserIDKey"

#define UserNameKey                 @"UserNameKey"

#define AllowShareKey               @"AllowShareKey"

#define AccessTokenSecretKey        @"AccessTokenSecretKey"


@class SNSConnector;

@protocol SNSConnectorDelegate <NSObject>

@optional

- (void)connectorAlreadyLoggedIn:(SNSConnector *)connector;
- (void)connectorDidLogIn:(SNSConnector *)connector;
- (void)connector:(SNSConnector *)connector didFailToLogInWithError:(NSError *)error;
- (void)connectorDidLogout:(SNSConnector *)connector;

- (void)connectorNotAuthorized:(SNSConnector *)connector;
- (void)connectorAuthorizeExpired:(SNSConnector *)connector;

- (void)connector:(SNSConnector *)connector requestDidFailWithError:(NSError *)error;
- (void)connector:(SNSConnector *)connector requestDidSucceedWithResult:(id)result;

@end

@interface SNSConnector : NSObject <SNSAuthorizeDelegate, SNSRequestDelegate, NSCoding>

@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *identifier;

@property (nonatomic, retain) NSMutableDictionary *keyObserver;
@property (nonatomic, retain) NSMutableDictionary *settingParams;

@property (nonatomic, retain) NSString *refreshToken;

@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, assign) BOOL isSignatureEnable;
@property (nonatomic, assign) BOOL isAllowShare;
@property (nonatomic, retain) SNSRequest *request;
@property (nonatomic, retain) SNSAuthorize *authorize;
@property (nonatomic, retain) id<SNSConnectorDelegate> delegate;

//- (id)init;

- (void)registerKey:(NSArray *)definedKeys;
- (SNSAuthorize *)getSNSAuthorize;
- (NSDictionary *)getRequiredParams;
- (NSDictionary *)getRequiredHeader;
- (NSString *)getAPIDomainURL;
- (NSString *)getExpiresInName;

- (void)readAuthInfo;
- (void)writeAuthInfo:(id)authInfo;
- (void)clearAuthInfo;

- (void)login;
- (void)loginUsingUserID:(NSString *)theUserID password:(NSString *)thePassword;
- (void)logout;

- (BOOL)isLoggedIn;

- (void)getRequestWithMethodName:(NSString *)methodName;
- (void)getRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params;
- (void)postRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params;
- (void)postRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params postDataType:(PostDataType)postDataType;
- (void)postRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params postDataType:(PostDataType)postDataType httpHeaderFields:(NSDictionary *)httpHeaderFields;

- (void)postRequestWithParams:(NSDictionary *)params;
- (void)postRequestWithParams:(NSDictionary *)params postDataType:(PostDataType)postDataType;

- (BOOL)is:(NSString *)url;

@end
