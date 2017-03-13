//
//  WMChartView.h
//  曲线-新算法
//
//  Created by thomas on 16/7/22.
//  Copyright © 2017年 thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WMChartViewDelegate

-(void)chartViewTouchPoint:(CGPoint)point;

@end

@interface WMChartView : UIScrollView

@property (nonatomic,strong) id<WMChartViewDelegate> touch_delegate;

@end

