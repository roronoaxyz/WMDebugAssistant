//
//  WMCpuHelper.h
//  Pods
//
//  Created by roronoa on 2016/12/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMCpuHelper : NSObject

/** 获取应用当前的 CPU */
+ (CGFloat)getCpuUsage;

/** 开始监听**/
- (void)startblock:(void (^)(CGFloat cpuUsage))block;
- (void)stop;
@end
