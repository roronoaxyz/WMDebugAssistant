//
//  WMChartView.h
//  曲线-新算法
//
//  Created by 邬志成 on 16/7/22.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WMChartViewDelegate

-(void)WMChartViewTouchPoint:(CGPoint)point;

@end

@interface WMChartView : UIScrollView

@property (nonatomic,strong) id<WMChartViewDelegate> touch_delegate;

@end

