//
//  WMFpsHelper.m
//  Pods
//
//  Created by roronoa on 2016/12/26.
//
//

#import "WMFpsHelper.h"         //fps 监听

/** fps **/
@interface WMFpsHelper () {
    NSTimeInterval lastTime;
    NSUInteger count;
}

@property (nonatomic, strong) CADisplayLink *displayLink;           //

@property (nonatomic, copy) void (^fpsBlock)(CGFloat fps);  //

@end

@implementation WMFpsHelper

- (id)init {
    self = [super init];

    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    if (lastTime == 0) {
        lastTime = self.displayLink.timestamp;
        return;
    }
    count++;
    NSTimeInterval timeout = self.displayLink.timestamp - lastTime;
    if (timeout < 1) return;
    lastTime = self.displayLink.timestamp;
    CGFloat fps = count / timeout;
    count = 0;

    if (self.fpsBlock) {
        self.fpsBlock(fps);
    }
}

/** 开始监听 **/
- (void)startblock:(void (^)(CGFloat fps))block {
    self.fpsBlock = block;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    self.fpsBlock = nil;

    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end
