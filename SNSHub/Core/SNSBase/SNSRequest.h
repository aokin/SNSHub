//
//  SNSRequest.h
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PostDataType)
{
    PostDataTypeNone,
	PostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	PostDataTypeMultipart,        // for uploading images and files.
};

#define HTTPGetMethod       @"GET"
#define HTTPPostMethod      @"POST"

#define TimeoutInterval   45.0f
#define StringBoundary    @"asdfjkhlkjahs213lk4jhasdfhlkjasdh214jkhasdasdfjhgiuytke1giuy1234"

@class SNSRequest;

@protocol SNSRequestDelegate <NSObject>

@optional

- (void)request:(SNSRequest *)request didReceiveResponse:(NSURLResponse *)response;

- (void)request:(SNSRequest *)request didReceiveRawData:(NSData *)data;

- (void)request:(SNSRequest *)request didFailWithError:(NSError *)error;

- (void)request:(SNSRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface SNSRequest : NSObject
{
    NSURLConnection         *connection;
    NSMutableData           *responseData;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property PostDataType postDataType;
@property (nonatomic, retain) NSDictionary *httpHeaderFields;
@property (nonatomic, retain) id<SNSRequestDelegate> delegate;

+ (SNSRequest *)requestWithURL:(NSString *)url
                    httpMethod:(NSString *)httpMethod
                        params:(NSDictionary *)params
                  postDataType:(PostDataType)postDataType
              httpHeaderFields:(NSDictionary *)httpHeaderFields
                      delegate:(id<SNSRequestDelegate>)delegate;

+ (SNSRequest *)requestWithAccessToken:(NSString *)accessToken
                                   url:(NSString *)url
                            httpMethod:(NSString *)httpMethod
                                params:(NSDictionary *)params
                          postDataType:(PostDataType)postDataType
                      httpHeaderFields:(NSDictionary *)httpHeaderFields
                              delegate:(id<SNSRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end
