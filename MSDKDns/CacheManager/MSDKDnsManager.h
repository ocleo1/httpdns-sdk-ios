/**
 * Copyright (c) Tencent. All rights reserved.
 */

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "MSDKDnsPrivate.h"

#if defined(__has_include)
    #if __has_include(<MSDK/BeaconBaseInterface.h>)
        #include <MSDK/BeaconBaseInterface.h>
    #endif

    #if __has_include("BeaconAPI_Base/BeaconBaseInterface.h")
        #include "BeaconAPI_Base/BeaconBaseInterface.h"
    #endif
#endif

@class MSDKDnsService;

@interface MSDKDnsManager : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary * domainDict;

+ (instancetype)shareInstance;

- (void)getHostByName:(NSString *)domain returnIps:(void (^)(NSArray * ipsArray))handler;
- (NSArray *)getHostByName:(NSString *)domain;
- (void)getHostsByNames:(NSArray *)domains returnIps:(void (^)(NSDictionary * ipsDict))handler;
- (NSDictionary *)getHostsByNames:(NSArray *)domains;
- (void)dnsHasDone:(MSDKDnsService *)service;
- (void)cacheDomainInfo:(NSDictionary *)domainInfo Domain:(NSString *)domain;
- (void)clearCacheForDomain:(NSString *)domain;
- (void)clearCacheForDomains:(NSArray *)domains;
- (void)clearCache;
- (NSDictionary *) getDnsDetail:(NSString *) domain;

@end
