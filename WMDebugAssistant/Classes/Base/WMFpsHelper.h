//
//  WMFpsHelper.h
//  Pods
//
//  Created by roronoa on 2016/12/26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** fps **/
@interface WMFpsHelper : NSObject

/** 开始监听 **/
- (void)startblock:(void (^)(CGFloat fps))block;
- (void)stop;

@end
