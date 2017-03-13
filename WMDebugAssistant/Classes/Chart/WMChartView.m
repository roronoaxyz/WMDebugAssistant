//
//  WMChartView.m
//  曲线-新算法
//
//  Created by thomas on 16/7/22.
//  Copyright © 2017年 thomas. All rights reserved.
//

#import "WMChartView.h"


@implementation WMChartView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touch_point = [touch locationInView:self];
    [self.touch_delegate chartViewTouchPoint:touch_point];
}

@end
