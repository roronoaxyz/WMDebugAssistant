//
//  WMChartView.m
//  曲线-新算法
//
//  Created by 邬志成 on 16/7/22.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import "WMChartView.h"


@implementation WMChartView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touch_point = [touch locationInView:self];
    [self.touch_delegate WMChartViewTouchPoint:touch_point];
}

@end
