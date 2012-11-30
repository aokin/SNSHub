//
//  ApiCore.h
//  SNSHub
//
//  Created by 旭东 吴 on 12-1-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccountInfo;

typedef NS_ENUM(NSInteger, SNSType) {
    SNSTypeNA = -1,
    SNSTypeSina = 0,
    SNSTypeTencent = 1,
    SNSTypeRenren = 2,
    SNSTypeKaixin = 3,
    SNSTypeTwitter = 4,
    SNSTypeFacebook = 5,
    SNSTypeWeixin = 6,
    SNSTypeDouban = 7,
    SNSTypeQZone = 8,
};

typedef enum _MessageType {
    ORIGIN,
    COMMENT,
    RESEND,
	SHARE,
    UID,
    HAS_IAMGE,
    IS_COMMENT
} MessageType;

#define RETURN_JSON_FORMAT          [@"." stringByAppendingString:ReturnTypeJSON]
#define RETURN_XML_FORMAT           [@"." stringByAppendingString:ReturnTypeXML]

#if defined(__cplusplus)
#define SNSHUB_CONSTANT extern "C"
#else
#define SNSHUB_CONSTANT extern
#endif

SNSHUB_CONSTANT NSString *const CancelOpenIDLoginNotification;

SNSHUB_CONSTANT NSString *const ResultKey;
typedef enum _Result {
    ResultFail,
    ResultSuccess
} Result;

SNSHUB_CONSTANT NSString *const MessageKey;
SNSHUB_CONSTANT NSString *const MessageTypeKey;
SNSHUB_CONSTANT NSString *const ErrorCodeKey;
SNSHUB_CONSTANT NSString *const ErrorInfoKey;
SNSHUB_CONSTANT NSString *const ServiceNameKey;

SNSHUB_CONSTANT NSString *const ReturnTypeJSON;
SNSHUB_CONSTANT NSString *const ReturnTypeXML;

enum _ReturnType {
    JSONFormat,
    XMLFormat
};

@protocol ApiCoreDelegate

@optional
- (BOOL)isLogin;

- (BOOL)isAllowShare;
- (void)setIsAllowShare:(BOOL)isAllowShare;

- (void)login;
- (void)refreshAccessToken:(void (^)(id data))completionHandler;
- (void)logout;
- (void)originMessage:(NSDictionary *)params;
- (void)commentMessage:(NSDictionary *)params;
- (void)resendMessage:(NSDictionary *)params;
- (void)shareMessage:(NSDictionary *)params;
- (void)isFollow:(NSDictionary *)params;
- (void)follow:(NSDictionary *)params;
- (void)getFollowIds;
- (void)getContents:(NSDictionary *)params;
- (void)statusesUpdateWithoutPic:(NSString *)status;
- (void)commentsCreate:(NSString *)comment withWeiboId:(NSString *)uid isComment:(NSString *)isComment;
- (void)statusesRepost:(NSString *)status withWeiboId:(NSString *)uid isComment:(NSString *)isComment;

@end

@protocol UserApiDelegate

@optional
- (void)didLogin:(AccountInfo *)accountInfo;
- (void)didLogin:(AccountInfo *)accountInfo withCompleteHandler:(void (^)(id data))completionHandler;
- (void)loginFail:(BOOL)userCancelled withError:(NSError*)error;
- (void)didLogout;
- (void)didIsFollow:(NSDictionary *)result;
- (void)didFollow:(NSDictionary *)result;
- (void)didPostMessage:(NSDictionary *)result;
- (void)didGetFollowIds;
- (void)didGetContents:(NSDictionary *)dic;
- (void)didOriginMessage;
- (void)didCommentMessage;
- (void)didResendMessage;
- (void)didShareMessage;
- (void)didGetError:(NSDictionary *)result;
@end

@interface ApiCore : NSProxy <ApiCoreDelegate>

@property (nonatomic, assign) id delegate;

+ (ApiCore *)shared;

@end
