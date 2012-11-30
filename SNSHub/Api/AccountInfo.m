//
//  AccountInfo.m
//  SNSHub
//
//  Created by 旭东 吴 on 12-2-9.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "AccountInfo.h"

@implementation AccountInfo

- (void)dealloc
{
    SNS_RELEASE(_accountId);
    SNS_RELEASE(_accountName);
    SNS_RELEASE(_accountImageUrl);
    SNS_RELEASE(_accountInfo);
    SNS_RELEASE(_accessToken);
    SNS_RELEASE(_accessSecret);
    
#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)initWithAccountId:(NSString *)openAccountId
     andOpenAccountName:(NSString *)openAccountName
 andOpenAccountImageUrl:(NSString *)openAccountImageUrl
         andAccountType:(NSInteger)openAccountType
{
    self = [super init];
    if (self) {
        self.accountId      = openAccountId;
        self.accountName    = openAccountName;
        self.accountType    = openAccountType;
        self.accountImageUrl = openAccountImageUrl;
        self.accountInfo = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)  {
        [self setAccountId:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accountId))]];
        [self setAccountName:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accountName))]];
        [self setAccountImageUrl:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accountImageUrl))]];
        [self setAccountInfo:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accountInfo))]];
        [self setAccessToken:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))]];
        [self setAccessSecret:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accessSecret))]];
        [self setAccountType:[aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(accountType))]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self accountId] forKey:NSStringFromSelector(@selector(accountId))];
    [aCoder encodeObject:[self accountName] forKey:NSStringFromSelector(@selector(accountName))];
    [aCoder encodeObject:[self accountImageUrl] forKey:NSStringFromSelector(@selector(accountImageUrl))];
    [aCoder encodeObject:[self accountInfo] forKey:NSStringFromSelector(@selector(accountInfo))];
    [aCoder encodeObject:[self accessToken] forKey:NSStringFromSelector(@selector(accessToken))];
    [aCoder encodeObject:[self accessSecret] forKey:NSStringFromSelector(@selector(accessSecret))];
    [aCoder encodeInteger:[self accountType] forKey:NSStringFromSelector(@selector(accountType))];
}

@end
