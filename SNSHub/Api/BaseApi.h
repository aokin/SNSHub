//
//  BaseApi.h
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCore.h"
#import "SNSConnector.h"
#import "AccountInfo.h"

#undef	AS_STATIC_PROPERTY
#define AS_STATIC_PROPERTY( __name ) \
		@property (nonatomic, readonly) NSString * __name; \
		+ (NSString *)__name;

#undef	DEF_STATIC_PROPERTY
#define DEF_STATIC_PROPERTY( __name ) \
		@dynamic __name; \
		+ (NSString *)__name \
		{ \
			static NSString * __local = nil; \
			if ( nil == __local ) \
			{ \
				__local = [[NSString stringWithFormat:@"%s", #__name] retain]; \
			} \
			return __local; \
		}
        
#undef	DEF_STATIC_PROPERTY2
#define DEF_STATIC_PROPERTY2( __name, __prefix ) \
		@dynamic __name; \
		+ (NSString *)__name \
		{ \
			static NSString * __local = nil; \
			if ( nil == __local ) \
			{ \
				__local = [[NSString stringWithFormat:@"%@.%s", __prefix, #__name] retain]; \
			} \
			return __local; \
		}

#undef	DEF_STATIC_PROPERTY3
#define DEF_STATIC_PROPERTY3( __name, __prefix, __prefix2 ) \
		@dynamic __name; \
		+ (NSString *)__name \
		{ \
			static NSString * __local = nil; \
			if ( nil == __local ) \
			{ \
				__local = [[NSString stringWithFormat:@"%@%@", __prefix, __prefix2] retain]; \
			} \
			return __local; \
		}

@interface BaseApi : NSObject <SNSConnectorDelegate, ApiCoreDelegate, NSCoding>

@property (nonatomic, retain) SNSConnector          *connector;
@property (nonatomic, retain) NSDictionary          *lastParams;
@property (nonatomic, retain) AccountInfo           *accountInfo;
@property (nonatomic, assign) id<UserApiDelegate>   delegate;

+ (id)createObject:(NSString *)apiName appKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI;
+ (id)createObject:(NSString *)apiName appKey:(NSString *)appKey appSecret:(NSString *)appSecret redirectURI:(NSString *)redirectURI appID:(NSString *)appID;

@end
