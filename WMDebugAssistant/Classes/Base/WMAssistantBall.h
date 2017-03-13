//
//  WMAssistantBall.h
//  EMLive
//
//  Created by Thomas Wang on 2016/11/25.
//  Copyright © 2016年 roronoa. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 悬浮助手 参考 DYYFloatWindow 的实现 **/
/** [UIApplication sharedApplication].windows[0] 上 **/
@interface WMAssistantBall : UIWindow

@property (nonatomic, strong) UIColor *ballColor;        //小球的颜色  默认白色
@property (nonatomic, strong) UIColor *shapeColor;        //移动时的光圈颜色  默认灰色
@property (nonatomic, strong) NSArray *addtionItems;        //额外的选项 用户可以自定义 nsstring , 大于6个不处理

@property (nonatomic, copy) void (^selectBlock)(NSString *title, UIButton *button);  //选择 返回的字符串是 addtionItems 中的内容

/** 显示 在属性配置完成之后 **/
/** 只能调用一次 后面几次不会生效 **/
- (void)doWork;

/** 通过标题获取按钮 默认的4个是 @"CPU",@"内存", @"流量",@"FPS" **/
- (UIButton *)buttonOfTitle:(NSString *)title;

//生成一张报表 类型   1 cpu ;2 内存 ; 3 网速
- (void)makeChart:(NSInteger)flag pCtrl:(UIViewController *)pCtrl;

@end

@interface UIViewController (WMAssistantBall)
@end
