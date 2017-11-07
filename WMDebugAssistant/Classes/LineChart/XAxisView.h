//
//  XAxisView.h
//  WMLineChartView
//
//  Created by thomas on 2017/9/31.
//  Copyright © 2017年 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XAxisView : UIView


@property (assign, nonatomic) CGFloat pointGap;//点之间的距离
@property (assign, nonatomic) BOOL isShowLabel;//是否显示文字
@property (strong, nonatomic) NSString* unit;//单位
@property (assign, nonatomic) BOOL isLongPress;//是不是长按状态
@property (assign, nonatomic) CGPoint currentLoc; //长按时当前定位位置
@property (assign, nonatomic) CGPoint screenLoc; //相对于屏幕位置

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin unit:(NSString*)unit;


@end
