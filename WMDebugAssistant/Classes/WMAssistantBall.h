//
//  WMAssistantBall.h
//  EMLive
//
//  Created by Thomas Wang on 2016/11/25.
//  Copyright © 2016年 roronoa. All rights reserved.
//

#import <UIKit/UIKit.h>

/** window上的悬浮球 DYYFloatWindow **/
@interface WMAssistantBall : UIWindow

//重要：所有图片都要是圆形的，程序里并没有自动处理成圆形
//
- (instancetype)initWithWindow:(UIWindow *)window;

// 显示（默认）
- (void)showWindow;

// 隐藏
- (void)dissmissWindow;

@end
