//
//  WMNetworkFlow.m
//  WMNetworkFlow
//
//  Created by MengWang on 16/12/22.
//  Copyright © 2017年 YukiWang. All rights reserved.
//

#import "WMNetworkFlow.h"       //流量信息
#include <ifaddrs.h>
#include <net/if.h>

@interface WMNetworkFlow()

@property (nonatomic, copy) void (^netBlock)(u_int32_t sendFlow, u_int32_t receivedFlow);  //每秒获取

@property (assign,nonatomic) uint32_t historySent;
@property (assign,nonatomic) uint32_t historyRecived;
@property (assign,nonatomic) BOOL     isFirst;

@property (nonatomic, strong) NSMutableArray *upFlows;
@property (nonatomic, strong) NSMutableArray *downFlows;
@property (nonatomic, strong)NSTimer *timer;

@end

@implementation WMNetworkFlow

- (instancetype)init {
    if ([super init]) {
        [self getNetflow];
    }
    
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;

    self.netBlock = nil;
}
/** 获取 下载 记录 **/
- (NSArray *)getDownFlow {
    return self.downFlows;
}

/** 获取 上传 记录 **/
- (NSArray *)getUpFlow {
    return self.upFlows;

}

- (void)startblock:(void (^)(u_int32_t sendFlow, u_int32_t receivedFlow))block {
    if (!self.upFlows) {
        self.upFlows = [NSMutableArray new];
    }
    if (!self.downFlows) {
        self.downFlows = [NSMutableArray new];
    }
    
    self.netBlock = block;
    self.isFirst = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getNetflow) userInfo:nil repeats:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

/** 是否激活中 **/
- (BOOL)isActived {
    return self.timer != nil;
}

/** 流量消耗状态 **/
- (void)getNetflow {
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;

    self.kWiFiSent = 0;
    self.kWiFiReceived = 0;
    self.kWWANSent = 0;
    self.kWWANReceived = 0;

    NSString *name = @"";

    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];

            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    self.kWiFiSent+=networkStatisc->ifi_obytes;
                    self.kWiFiReceived+=networkStatisc->ifi_ibytes;
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    self.kWWANSent+=networkStatisc->ifi_obytes;
                    self.kWWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }

    //第一次不统计
    if (self.isFirst) {
        self.isFirst = NO;

        self.historySent = self.kWiFiSent + self.kWWANSent;
        self.historyRecived = self.kWiFiReceived + self.kWWANReceived;
    }
    else {
        uint32_t nowSent = (self.kWiFiSent + self.kWWANSent - self.historySent);
        uint32_t nowRecived = (self.kWiFiReceived + self.kWWANReceived - self.historyRecived);

        //记录
        [self.upFlows addObject:@{@"date":[NSDate date], @"value":@(nowSent / 1024.0f / 1024.0f)}];
        [self.downFlows addObject:@{@"date":[NSDate date], @"value":@(nowRecived / 1024.0f / 1024.0f)}];

        //记录10分钟
        if (self.upFlows.count > 600) {
            [self.upFlows removeObjectAtIndex:0];
        }

        //记录10分钟
        if (self.downFlows.count > 600) {
            [self.downFlows removeObjectAtIndex:0];
        }

        if (self.netBlock) {
            self.netBlock(nowSent, nowRecived);
        }
    }
}

@end
