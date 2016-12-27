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

@property (nonatomic, copy) void (^memBlock)(CGFloat memUsage);  //每秒获取

@end

@implementation WMMemeryHelper

- (void)dealloc {
    [self stop];

    self.memBlock = nil;
}


- (void)startblock:(void (^)(CGFloat memUsage))block {
    self.memBlock = block;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMemUsage) userInfo:nil repeats:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

/**  **/
- (void)getMemUsage {
    if (self.memBlock) {
        CGFloat u = [WMMemeryHelper getUsedMemory];
        self.memBlock(u);
    }
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
