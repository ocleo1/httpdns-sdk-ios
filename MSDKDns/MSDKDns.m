/**
 * Copyright (c) Tencent. All rights reserved.
 */

#import "MSDKDns.h"
#import "MSDKDnsService.h"
#import "MSDKDnsLog.h"
#import "MSDKDnsManager.h"
#import "MSDKDnsNetworkManager.h"
#import "MSDKDnsInfoTool.h"
#import "MSDKDnsParamsManager.h"


@implementation MSDKDns

static MSDKDns * _sharedInstance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MSDKDns alloc] init];
    });
    return _sharedInstance;
}

- (instancetype) init {
    if (self = [super init]) {
        //开启网络切换，及前后台切换的监听
        [MSDKDnsNetworkManager start];
    }
    return self;
}

- (BOOL) initConfig:(NSString *)appId dnsId:(int)dnsId dnsKey:(NSString *)dnsKey dnsIp:(NSString *)dnsIp debug:(BOOL)debug timeout:(int)timeout {
    return [self initConfig:appId dnsId:dnsId dnsKey:dnsKey dnsIp:dnsIp debug:debug timeout:timeout channel:DES_HTTP_CHANNEL];
}

- (BOOL) initConfig:(NSString *)appId dnsId:(int)dnsId dnsKey:(NSString *)dnsKey dnsIp:(NSString *)dnsIp debug:(BOOL)debug timeout:(int)timeout channel:(NSString *)channel {
    [[MSDKDnsLog sharedInstance] setEnableLog:debug];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMAppId:appId MTimeOut:timeout MChannel:channel];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsId:dnsId MDnsKey:dnsKey];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsIp:dnsIp];
    return YES;
}

- (BOOL) initConfig:(NSString *)appId dnsIp:(NSString *)dnsIp debug:(BOOL)debug timeout:(int)timeout {
    [[MSDKDnsLog sharedInstance] setEnableLog:debug];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMAppId:appId MTimeOut:timeout];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsIp:dnsIp];
    return YES;
}

- (BOOL) WGSetDnsAppKey:(NSString *) appkey DnsID:(int)dnsid DnsKey:(NSString *)dnsKey DnsIP:(NSString *)dnsip Debug:(BOOL)debug TimeOut:(int)timeout
{
    return [self WGSetDnsAppKey:appkey DnsID:dnsid DnsKey:dnsKey DnsIP:dnsip Debug:debug TimeOut:timeout channel:DES_HTTP_CHANNEL];
}

//channel
- (BOOL) WGSetDnsAppKey:(NSString *) appkey DnsID:(int)dnsid DnsKey:(NSString *)dnsKey DnsIP:(NSString *)dnsip Debug:(BOOL)debug TimeOut:(int)timeout channel:(NSString *)channel
{
    [[MSDKDnsLog sharedInstance] setEnableLog:debug];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMAppId:appkey MTimeOut:timeout MChannel:channel];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsId:dnsid MDnsKey:dnsKey];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsIp:dnsip];
    return YES;
}

- (BOOL) WGSetDnsAppKey:(NSString *) appkey DnsIP:(NSString *)dnsip Debug:(BOOL)debug TimeOut:(int)timeout {
    [[MSDKDnsLog sharedInstance] setEnableLog:debug];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMAppId:appkey MTimeOut:timeout];
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMDnsIp:dnsip];
    return YES;
}

- (BOOL) WGSetDnsOpenId:(NSString *)openId {
    if (!openId || ([openId length] == 0)) {
        [[MSDKDnsParamsManager shareInstance] msdkDnsSetMOpenId:HTTP_DNS_UNKNOWN_STR];
        return NO;
    }
    // 保存openid
    [[MSDKDnsParamsManager shareInstance] msdkDnsSetMOpenId:openId];
    return YES;
}

- (NSArray *) WGGetHostByName:(NSString *)domain {
    @synchronized(self) {
        NSArray * dnsResult = @[@"0", @"0"];
        MSDKDNSLOG(@"GetHostByName:%@",domain);
        if (!domain || domain.length == 0) {
            //请求域名为空，返回空
            MSDKDNSLOG(@"MSDKDns Result is Empty!");
            return dnsResult;
        }
        //进行httpdns请求
        NSDate * date = [NSDate date];
        //进行httpdns请求
        dnsResult = [[MSDKDnsManager shareInstance] getHostByName:domain];
        NSTimeInterval time_consume = [[NSDate date] timeIntervalSinceDate:date] * 1000;
        MSDKDNSLOG(@"MSDKDns WGGetHostByName Total Time Consume is %.1fms", time_consume);
        NSMutableString * ipsStr = [NSMutableString stringWithString:@""];
        for (int i = 0; i < dnsResult.count; i++) {
            NSString * ip = dnsResult[i];
            [ipsStr appendFormat:@"%@,",ip];
        }
        MSDKDNSLOG(@"%@, MSDKDns Result is:%@",domain, ipsStr);
        return dnsResult;
    }
}

- (void)WGGetHostByNameAsync:(NSString *)domain returnIps:(void (^)(NSArray *))handler {
    @synchronized(self) {
        MSDKDNSLOG(@"GetHostByNameAsync:%@",domain);
        if (!domain || domain.length == 0) {
            //请求域名为空，返回空
            MSDKDNSLOG(@"MSDKDns Result is Empty!");
            NSArray * dnsResult = @[@"0", @"0"];
            if (handler) {
                handler(dnsResult);
                handler = nil;
            }
            return;
        }
        NSDate * date = [NSDate date];
        [[MSDKDnsManager shareInstance] getHostByName:domain returnIps:^(NSArray *ipsArray) {
            NSTimeInterval time_consume = [[NSDate date] timeIntervalSinceDate:date] * 1000;
            MSDKDNSLOG(@"MSDKDns WGGetHostByNameAsync Total Time Consume is %.1fms", time_consume);
            if (ipsArray) {
                NSArray * dnsResult = [[NSArray alloc] initWithArray:ipsArray];
                NSMutableString * ipsStr = [NSMutableString stringWithString:@""];
                for (int i = 0; i < dnsResult.count; i++) {
                    NSString * ip = dnsResult[i];
                    [ipsStr appendFormat:@"%@,",ip];
                }
                MSDKDNSLOG(@"%@, MSDKDns Result is:%@",domain, ipsStr);
                if (handler) {
                    handler(dnsResult);
                }
            } else {
                NSArray * dnsResult = @[@"0", @"0"];
                if (handler) {
                    handler(dnsResult);
                }
            }
        }];
    }
}

- (void) WGSetHijackDomainArray:(NSArray *)hijackDomainArray {
    if (hijackDomainArray) {
        [[MSDKDnsParamsManager shareInstance] setHijackDomainArray:[hijackDomainArray copy]];
    }
}

- (void) WGSetNoHijackDomainArray:(NSArray *)noHijackDomainArray {
    if (noHijackDomainArray) {
        [[MSDKDnsParamsManager shareInstance] setNoHijackDomainArray:[noHijackDomainArray copy]];
    }
}

- (NSDictionary *) WGGetDnsDetail:(NSString *) domain {
    return [[MSDKDnsManager shareInstance] getDnsDetail:domain];
}

@end
