//
//  WMMemeryHelper.h
//  Pods
//
//  Created by roronoa on 2016/12/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMMemeryHelper : NSObject

/** 获取当前应用的内存 */
+ (CGFloat)getUsedMemory;

/** 获取 内存 记录 **/
- (NSArray *)getRecords;

/** 是否激活中 **/
- (BOOL)isActived;

/** 开始监听**/
- (void)startblock:(void (^)(CGFloat memUsage))block;
- (void)stop;

@end
