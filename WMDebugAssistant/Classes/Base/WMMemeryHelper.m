//
//  WMMemeryHelper.m
//  Pods
//
//  Created by roronoa on 2016/12/27.
//
//

#import "WMMemeryHelper.h"
#import <mach/mach.h>

@interface WMMemeryHelper ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *records;

@property (nonatomic, copy) void (^memBlock)(CGFloat memUsage);  //每秒获取

@end

@implementation WMMemeryHelper

- (void)dealloc {
    [self stop];

    self.memBlock = nil;
}


- (void)startblock:(void (^)(CGFloat memUsage))block {
    if (!self.records) {
        self.records = [NSMutableArray new];
    }

    self.memBlock = block;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMemUsage) userInfo:nil repeats:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

/** 是否激活中 **/
- (BOOL)isActived {
    return self.timer != nil;
}

/**  **/
- (void)getMemUsage {
    CGFloat u = [WMMemeryHelper getUsedMemory];
    [self.records addObject:@{@"date":[NSDate date], @"value":@(u)}];

    //记录10分钟
    if (self.records.count > 600) {
        [self.records removeObjectAtIndex:0];
    }

    if (self.memBlock) {
        self.memBlock(u);
    }
}

/** 获取 内存 记录 **/
- (NSArray *)getRecords {
    return self.records;
}

/** 获取当前应用的内存 */
+ (CGFloat)getUsedMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);

    if(kernReturn != KERN_SUCCESS) {
        return 0;
    }

    return taskInfo.resident_size / 1024.0 / 1024.0;
}

@end
