//
//  RenrenEngine.m
//  SNSHub
//
//  Created by William on 12-10-30.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import "RenrenConnector.h"
#import "RenrenAuthorize.h"
#import "CategoryUtil.h"
#import "ApiCore.h"

@implementation RenrenConnector

- (void)dealloc
{
    SNS_RELEASE(_scope);

#if !ARC_ENABLED
    [super dealloc];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerKey:@[ScopeKey]];
        [self readAuthInfo];
        [self setIsSignatureEnable:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    self = [super initWithCoder:aDecoder];
    if (self)  {
        [self registerKey:@[ScopeKey]];
        [self readAuthInfo];
        [self setIsSignatureEnable:YES];
    }
    return self;
}

- (void)readAuthInfo
{
    [super readAuthInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *theScope = [userDefaults objectForKey:[[self keyObserver] objectForKey:ScopeKey]];

    [self setScope:theScope];
}

- (void)writeAuthInfo:(id)authInfo
{
    [super writeAuthInfo:authInfo];

    NSString *theScope = [authInfo objectForKey:@"scope"];
    
    [self setScope:theScope];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:[self scope] forKey:[[self keyObserver] objectForKey:ScopeKey]];
}

- (SNSAuthorize *)getSNSAuthorize
{
    return SNS_AUTORELEASE([[RenrenAuthorize alloc] initWithAppKey:[self appKey] appSecret:[self appSecret]]);
}

- (NSDictionary *)getRequiredParams
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"v", ReturnTypeJSON, @"format", nil];
}

- (NSString *)generateBaseString:(NSDictionary *)params
{
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *pairs = SNS_AUTORELEASE([@[] mutableCopy]);
    for (NSString *key in sortedKeys) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }   
    }
    
    NSString *baseString = [NSString stringWithFormat:@"%@", [pairs componentsJoinedByString:@""]];
    baseString = [baseString stringByAppendingString:[self appSecret]];
    
    return baseString;
}

- (NSString *)generateSignature:(NSString *)baseString
{
    return [baseString MD5EncodedString];
}

- (NSDictionary *)request:(SNSSignatureRequest *)request willCalculateSignature:(NSDictionary *)params
{
    NSMutableDictionary *tempParams = SNS_AUTORELEASE([[NSMutableDictionary alloc] initWithDictionary:params]);
    
    NSString *baseString = [self generateBaseString:tempParams];
    NSString *signature = [self generateSignature:baseString];
    
    [tempParams setValue:signature forKey:@"sig"];
    
    return [NSDictionary dictionaryWithDictionary:tempParams];
}

- (BOOL)is:(NSString *)url
{
    return [[[[self request] params] objectForKey:@"method"] hasPrefix:url];
}

@end