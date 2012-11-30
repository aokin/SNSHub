//
//  CategoryUtil.h
//  SNSHub
//
//  Created by William on 12-11-5.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

//Functions for Encoding Data.
@interface NSData (SNSEncode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (SNSEncode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;

@end

@interface NSString (StringCheck)
- (BOOL)isEmpty;
- (BOOL)isValidateEmail;
- (NSString *)defaultValue;
@end

@interface NSNull (EmptyCheck)
- (BOOL)isEmpty;
- (NSString *)defaultValue;
@end

@interface NSString (SNSUtil) 

+ (NSString *)GUIDString;
- (NSString *)convertToJSONObject;

@end


