//
//  WMChartLine.h
//  曲线-新算法
//
//  Created by 邬志成 on 16/7/20.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMChartView.h"

typedef enum : NSInteger {
    WMChartLineTypeBroken = 0,//broken line 折线
    WMChartLineTypeCurve  //曲线
}  WMChartLineType;

@interface WMChartLine : UIView<WMChartViewDelegate>

#pragma mark - 必须设置
/** X 坐标轴上的值 (字符串)*/
@property (nonnull,strong,nonatomic) NSArray<NSString*> *x_values;
/* Y坐标上的值 支持多组值 (字符串)*/
@property (nonnull,strong,nonatomic) NSArray<NSArray<NSString*> * > *y_values;
/* 折线的名称/类别 (有几条直线就有几个名字,默认无) */
@property (nonnull,strong,nonatomic) NSArray<NSString*> *y_titles;
/* 折线的名称/类别 的单位 */
@property (nonnull,strong,nonatomic) NSString *y_unit;
/* 折线的颜色数组(默认随机方法) */
@property (nonnull,strong,nonatomic) NSArray<UIColor *> *colorsArray;

/* 以上 设置完毕后才调用绘图方法 */
-(void)startDrawWithLineType:(WMChartLineType)lineType;

#pragma mark - 可选设置
/**
 *  设置最小的 Y 值(默认为0) ,设置时需注意: 如果设置的值大于最大的 Y 值, 则设置为无效;
 *
 *  @param minValue 最小的 Y 值 (设置负数可以自动设置 Y 值,从最小的 Y 值起步)
 */
- (void)setMinY:(CGFloat)minValue;

/**
 *  设置 X 坐标轴的位置
 *
 *  @param minValue 对应的 Y 值(默认为最小值)
 */
- (void)setXCoordinatesLocationInYValue:(CGFloat)yValue;

/**
 *  设置 Y 轴刻度的个数
 *
 *  @param tipCont 默认为自动
 */
- (void)setCoords_Y_Tips:(NSInteger)tipCont;

/**
 *  如果坐标轴中存在负数,调用此函数功能是对称显示坐标
 *
 *  @param show 是否显示0点刻度
 */
- (void)setCoordPlusAndMinusSymmetryShowZeroPoint:(BOOL)show;
@end

