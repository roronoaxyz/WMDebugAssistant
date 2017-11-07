//
//  YAxisView.h
//  WMLineChartView
//
//  Created by thomas on 2017/9/31.
//  Copyright © 2017年 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YAxisView : UIView

- (id)initWithFrame:(CGRect)frame yMax:(CGFloat)yMax yMin:(CGFloat)yMin unit:(NSString*)unit;

@end
