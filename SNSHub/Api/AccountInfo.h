//
//  AccountInfo.h
//  SNSHub
//
//  Created by 旭东 吴 on 12-2-9.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString    *accountId;
@property (nonatomic, strong) NSString    *accountName;
@property (nonatomic, strong) NSString    *accountImageUrl;
@property (nonatomic, strong) NSDictionary *accountInfo;
@property (nonatomic, assign) NSInteger   accountType;
@property (nonatomic, strong) NSString    *accessToken;
@property (nonatomic, strong) NSString    *accessSecret;

- (id)initWithAccountId:(NSString *)openAccountId andOpenAccountName:(NSString *)openAccountName andOpenAccountImageUrl:(NSString *)openAccountImageUrl andAccountType:(NSInteger)openAccountType;

@end
