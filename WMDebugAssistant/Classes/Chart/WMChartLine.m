//
//  WMChartLine.m
//  曲线-新算法
//
//  Created by 邬志成 on 16/7/20.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import "WMChartLine.h"
#import "UIView+WM.h"
#import "UIBezierPath+WM.h"

/*计算的宏*/
#define ABS_VALUE(x,y) (MAX(x,y)-MIN(x,y))
/*配置线条的宏*/
#define Arrows_Size 3 //箭头半径
#define Arrows_Height 6 //箭头的高度
#define Coords_lineColor [UIColor blackColor].CGColor //坐标线的颜色
#define Coords_Y_Tip_Width 6 //刻度宽度
#define Coords_Y_LableFont_Size 12 //Y轴标签的字体大小
#define Coords_X_LableFont_Size 10 //X轴标签的字体大小
#define Coords_X_Lable_Space 10 //X轴标签间距
#define Coords_X_Verticlal_Line_Color [UIColor lightGrayColor].CGColor //垂直于X轴的线条颜色
#define Coords_X_Verticlal_Line_Width 0.8 //垂直于X轴的线条宽度
#define Coords_Values_Line_Width 1.8 //折线的线条宽度
#define Coords_Legend_Font_Size 15 //图例的字体大小
#define Coords_Y_Verticlal_Line_Color [UIColor lightGrayColor].CGColor //垂直于Y轴的线条颜色
#define Coords_Y_Verticlal_Line_Width 0.8 //垂直于Y轴的线条宽度
#define Show_Coords_X_Verticlal_Line YES // 显示垂直于X轴的线条
#define Show_Coords_Y_Verticlal_Line YES //显示垂直于Y轴的线条

@interface WMChartLine()
//转换后的坐标点
@property (strong,nonatomic) NSArray *coords_y_values;

@property (strong,nonatomic) NSArray *coords_x_values;

//固定Y坐标的区域
@property (assign,nonatomic) UIView *y_coord_View;

//绘图的区域
@property (assign,nonatomic) WMChartView *draw_view;

//缩放因子
@property (assign,nonatomic) CGFloat scale_Value;

//X轴label的宽度
@property (assign,nonatomic) CGFloat coords_x_label_width;


/**
 *  各种距离
 */
@property (assign,nonatomic) CGFloat offset_top;

@property (assign,nonatomic) CGFloat offset_bottom;

@property (assign,nonatomic) CGFloat offset_left;

@property (assign,nonatomic) CGFloat offset_right;

@property (assign,nonatomic) CGFloat minY;

@property (assign,nonatomic) CGFloat x_coord_location;

@end

@implementation WMChartLine{
    
    UIView *legendView; //图例视图
    NSArray *coords_y_tips;
    BOOL isCustemY;
    NSInteger Coords_Y_Tip;
    BOOL showZeroPoint; //是否显示0刻度点
    CGFloat maxY;
}

-(void)startDrawWithLineType:(WMChartLineType)lineType{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    if (![self PASS_checkErrors]) {
        return;
    }
    /******/
    
    /*默认值*/
    [self setDefaultValue];
    //转换坐标系
    [self drawCoordindined_Y];
    [self drawCoordindined_X];
    [self swithYValues];
    [self swithXValuesWithLabelWidth:_coords_x_label_width];
    if (lineType == WMChartLineTypeBroken) {
        [self makePolyLineWithLabelWidth:_coords_x_label_width];
    }else{
        [self makecurveWithLabelWidth:_coords_x_label_width];
    }
    [self addLegend];
}

- (void)setDefaultValue{
    
#warning 这里修改到视图边距的值
    self.offset_top = 40;
    self.offset_left = 60;
    self.offset_right = 10;
    self.offset_bottom = 30;
    
    /**************以下设置请勿更改****************/
    
    if (Coords_Y_Tip <= 0) {
        Coords_Y_Tip = [self getTipsWithValue:[self getMaxYValue]];
    }
    
    if (self.minY == 0) {
        CGFloat min_yValue = [self getMinYValue];
        if (min_yValue < 0) {
            self.minY = min_yValue;
        }else{
            self.minY = 0;
        }
    }
    
    if (!isCustemY) {
        if (self.minY != 0) {
            self.x_coord_location = self.minY;
        }else{
            self.x_coord_location = 0;
        }
    }
    
}
#pragma mark -这些都是坐标系相关的
//画坐标系
-(void)drawCoordindined_X{
    
    WMChartView *chtView = [[WMChartView alloc]initWithFrame:CGRectMake(self.offset_left - Arrows_Size, 0, self.width - self.offset_right + Arrows_Size - self.offset_left, self.height)];
    chtView.touch_delegate = self;
    //不允许弹跳效果
    chtView.bounces = NO;
    _draw_view = chtView;
    //获取最大的label的尺寸
    CGSize max_label_size = [self getX_MaxLabelSize];
    _coords_x_label_width = max_label_size.width;
    //横坐标总长度
    CGFloat coord_x_lenth = (max_label_size.width + Coords_X_Lable_Space) * _x_values.count;
    //设置contentSize
    _draw_view.contentSize = CGSizeMake(coord_x_lenth + self.offset_right, 0);
    
    UIBezierPath *coords_path = [UIBezierPath bezierPath];
    
    //画一条横坐标的线
    //x坐标最右端顶点x值
    CGFloat coord_x_right_value = coord_x_lenth ;
    //x坐标轴的Y值
    CGFloat tmp_value = self.x_coord_location - self.minY;
    tmp_value = self.frame.size.height - tmp_value * _scale_Value - self.offset_bottom;
    CGFloat coord_x_custem_y_value = tmp_value;
    
    
    CGFloat coord_x_yValue = _draw_view.height - self.offset_bottom;
    //画横坐标坐标轴
    UIBezierPath *coord_x_path = [UIBezierPath bezierPath];
    
    [coord_x_path moveToPoint:CGPointMake(0, coord_x_custem_y_value)];
    [coord_x_path addLineToPoint:CGPointMake(coord_x_right_value, coord_x_custem_y_value)];
    
    //画横坐标的箭头
    UIBezierPath *coordsArrow_path = [UIBezierPath bezierPath];
    [coordsArrow_path moveToPoint:CGPointMake(coord_x_right_value - Arrows_Height, coord_x_custem_y_value - Arrows_Size)];
    [coordsArrow_path addLineToPoint:CGPointMake(coord_x_right_value, coord_x_custem_y_value)];
    [coordsArrow_path addLineToPoint:CGPointMake(coord_x_right_value - Arrows_Height, coord_x_custem_y_value + Arrows_Size)];
    //绘制垂直于 Y 轴的线
    if(Show_Coords_Y_Verticlal_Line){
        UIBezierPath *Coords_Y_Verticlal_Line_path = [UIBezierPath bezierPath];
        for (NSNumber *value in coords_y_tips) {
            @autoreleasepool {
                CGFloat y_tip = [value floatValue];
                UIBezierPath *tip_path = [UIBezierPath bezierPath];
                [tip_path moveToPoint:CGPointMake(0, y_tip)];
                [tip_path addLineToPoint:CGPointMake(coord_x_right_value - (max_label_size.width + Coords_X_Lable_Space) / 2.0f, y_tip)];
                [Coords_Y_Verticlal_Line_path appendPath:tip_path];
            }
        }
        
        //添加y坐标竖线的图层
        CAShapeLayer *coords_y_Verticlal_Line_layer = [[CAShapeLayer alloc]init];
        coords_y_Verticlal_Line_layer.frame = _draw_view.bounds;
        coords_y_Verticlal_Line_layer.path = Coords_Y_Verticlal_Line_path.CGPath;
        coords_y_Verticlal_Line_layer.lineWidth = Coords_Y_Verticlal_Line_Width;
        coords_y_Verticlal_Line_layer.strokeColor = Coords_Y_Verticlal_Line_Color;
        coords_y_Verticlal_Line_layer.fillColor = [UIColor clearColor].CGColor;
        [_draw_view.layer addSublayer:coords_y_Verticlal_Line_layer];
        
    }
    
    //绘制X轴的竖线
    
    UIBezierPath *Coords_X_Verticlal_Line_path = [UIBezierPath bezierPath];
    CGFloat coords_max_y = coord_x_yValue;
    CGFloat coords_min_y = coords_max_y - ([self getMaxYValue] - self.minY) * self.scale_Value;
    
    CGFloat label_CenterY = coord_x_custem_y_value + [self getLabelWidthWithStr:@"字符串" font:[UIFont systemFontOfSize:Coords_X_LableFont_Size]].height / 1.5;//标签的中心Y
    [_x_values enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            CGFloat label_CenterX = ((float)idx + 0.5f) * (max_label_size.width + Coords_X_Lable_Space);
            UILabel *x_label_tmp = [[UILabel alloc]init];
            x_label_tmp.width = max_label_size.width;
            x_label_tmp.height = self.offset_bottom;
            x_label_tmp.text = obj;
            x_label_tmp.center = CGPointMake(label_CenterX, label_CenterY);
            x_label_tmp.textAlignment = NSTextAlignmentCenter;
            x_label_tmp.font = [UIFont systemFontOfSize:Coords_X_LableFont_Size];
            [_draw_view addSubview:x_label_tmp];
            if(Show_Coords_X_Verticlal_Line){
                UIBezierPath *coords_x_V_tmp = [UIBezierPath bezierPath];
                [coords_x_V_tmp moveToPoint:CGPointMake(label_CenterX, coords_min_y)];
                [coords_x_V_tmp addLineToPoint:CGPointMake(label_CenterX, coords_max_y)];
                [Coords_X_Verticlal_Line_path appendPath:coords_x_V_tmp];
            }
        }
    }];
    if(Show_Coords_X_Verticlal_Line){
        //添加x坐标竖线的图层
        CAShapeLayer *coords_x_Verticlal_Line_layer = [[CAShapeLayer alloc]init];
        coords_x_Verticlal_Line_layer.frame = _draw_view.bounds;
        coords_x_Verticlal_Line_layer.path = Coords_X_Verticlal_Line_path.CGPath;
        coords_x_Verticlal_Line_layer.lineWidth = Coords_X_Verticlal_Line_Width;
        coords_x_Verticlal_Line_layer.strokeColor = Coords_X_Verticlal_Line_Color;
        coords_x_Verticlal_Line_layer.fillColor = [UIColor clearColor].CGColor;
        [_draw_view.layer addSublayer:coords_x_Verticlal_Line_layer];
    }
    
    //汇总path
    [coords_path appendPath:coord_x_path];
    [coords_path appendPath:coordsArrow_path];
    
    
    
    //添加坐标的图层
    CAShapeLayer *coords_layer = [[CAShapeLayer alloc]init];
    coords_layer.frame = _draw_view.bounds;
    coords_layer.path = coords_path.CGPath;
    coords_layer.lineWidth = 1.0f;
    coords_layer.strokeColor = Coords_lineColor;
    coords_layer.fillColor = [UIColor clearColor].CGColor;
    [_draw_view.layer addSublayer:coords_layer];
    [self addSubview:_draw_view];
    
}


#pragma mark - 自动获取刻度个数
- (NSInteger)getTipsWithValue:(CGFloat)value{
    NSInteger Multiple = 1;
    if ((int)value != value) {
        if (value * 10 == (int)(value * 10)) {
            Multiple = 10;
        }else{
            Multiple = 100;
        }
    }
    NSInteger maxTips = (self.height - self.offset_top - self.offset_bottom) / [self getLabelWidthWithStr:@"测试" font:[UIFont systemFontOfSize:Coords_Y_LableFont_Size]].height;
    if (maxTips < 5) {
        return maxTips;
    }
    for (int i = 5; i < maxTips; i ++) {
        if ((int)(value * Multiple) % (i * Multiple) == 0) {
            return i - 1;
            break;
        }
    }
    return 5;
}

#pragma mark 设置坐标轴对称
- (void)setCoordPlusAndMinusSymmetryShowZeroPoint:(BOOL)show{
    showZeroPoint = show;
    if ([self getMinYValue] < 0) {
        
        if (- [self getMinYValue] > [self getMaxYValue]) {
            maxY = - [self getMinYValue];
        }else{
            
            _minY = - [self getMaxYValue];
            
        }
    }
}

/**
 *  画纵坐标
 */
-(void)drawCoordindined_Y{
    //最大坐标(到顶)
    CGFloat maxY_value = [self getMaxYValue] * 1.0f - self.minY;
    if (maxY_value == 0) {
        maxY_value = 1;
    }
    //步进值
    CGFloat step_value = (maxY_value / Coords_Y_Tip);
    
    UIView *y_CoordView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.offset_left, self.height)];
    _y_coord_View = y_CoordView;
    
    _scale_Value = (_y_coord_View.height - self.offset_bottom - self.offset_top) * 1.0f / maxY_value;
    
    //绘制竖线
    
    CGFloat coord_y_top = self.offset_top / 3.0f;
    UIBezierPath *y_coord_path = [UIBezierPath bezierPath];
    [y_coord_path moveToPoint:CGPointMake(_y_coord_View.width - Arrows_Size, coord_y_top)];
    [y_coord_path addLineToPoint:CGPointMake(_y_coord_View.width - Arrows_Size, _y_coord_View.height - self.offset_bottom + 0.2)];
    //    [y_coord_path addLineToPoint:CGPointMake(_y_coord_View.width, _y_coord_View.height - self.offset_bottom)];
    
    /**
     *  绘制箭头
     */
    UIBezierPath *arrows_path = [UIBezierPath bezierPath];
    [arrows_path moveToPoint:CGPointMake(_y_coord_View.width - 2 * Arrows_Size, coord_y_top + Arrows_Height)];
    [arrows_path addLineToPoint:CGPointMake(_y_coord_View.width - Arrows_Size, coord_y_top)];
    [arrows_path addLineToPoint:CGPointMake(_y_coord_View.width, coord_y_top + Arrows_Height)];
    
    //绘制刻度
    
    UIBezierPath *coords_steps = [UIBezierPath bezierPath];
    
    UIFont *font = [UIFont systemFontOfSize:Coords_Y_LableFont_Size];
    NSMutableArray *tips_array = [NSMutableArray array];
    BOOL isShowZeroPoint = NO; //是否包含零点
    for (int i = 0; i <= Coords_Y_Tip; i ++) {
        @autoreleasepool {
            
            UILabel *y_label_tmp = [[UILabel alloc]init];
            CGFloat y_value;
            
            if (step_value < Coords_Y_Tip) {
                y_label_tmp.text = [NSString stringWithFormat:@"%.1f",(step_value * i + self.minY)];
                y_value = _y_coord_View.height - ((step_value * i) * _scale_Value + self.offset_bottom);
            }else{
                
                y_label_tmp.text = [NSString stringWithFormat:@"%0.1f",((step_value) * i + self.minY)];
                y_value = _y_coord_View.height - (step_value * i * _scale_Value + self.offset_bottom);
            }
            
            if (!isShowZeroPoint) {
                isShowZeroPoint = step_value * i == 0 ? YES:NO;
            }
            y_label_tmp.font = font;
            y_label_tmp.size = [self getLabelWidthWithStr:y_label_tmp.text font:font];
            y_label_tmp.height = Coords_Y_LableFont_Size;
            y_label_tmp.center = CGPointMake(_y_coord_View.width - Arrows_Size * 2 - Coords_Y_Tip_Width - y_label_tmp.width / 2.0f, y_value);
            [_y_coord_View addSubview:y_label_tmp];
            
            
            if (i == Coords_Y_Tip && !isShowZeroPoint && showZeroPoint) {
                //绘制0刻度点
                UILabel *y_label_zero = [[UILabel alloc]init];
                CGFloat zero_value;
                y_label_zero.text = [NSString stringWithFormat:@"%0.1f",0.0];
                
                CGFloat tmp_value = 0 - self.minY;
                zero_value = self.frame.size.height - tmp_value * _scale_Value - self.offset_bottom;
                y_label_zero.font = font;
                y_label_zero.size = [self getLabelWidthWithStr:y_label_zero.text font:font];
                y_label_zero.height = Coords_Y_LableFont_Size;
                y_label_zero.center = CGPointMake(_y_coord_View.width - Arrows_Size * 2 - Coords_Y_Tip_Width - y_label_zero.width / 2.0f, zero_value);
                [_y_coord_View addSubview:y_label_zero];
                
                UIBezierPath *tmp_path = [UIBezierPath bezierPath];
                [tmp_path moveToPoint:CGPointMake(_y_coord_View.width - Arrows_Size - Coords_Y_Tip_Width, zero_value)];
                [tmp_path addLineToPoint:CGPointMake(_y_coord_View.width - Arrows_Size, zero_value)];
                [coords_steps appendPath:tmp_path];
                
            }
            UIBezierPath *tmp_path = [UIBezierPath bezierPath];
            [tmp_path moveToPoint:CGPointMake(_y_coord_View.width - Arrows_Size - Coords_Y_Tip_Width, y_value)];
            [tmp_path addLineToPoint:CGPointMake(_y_coord_View.width - Arrows_Size, y_value)];
            [tips_array addObject:@(y_value)];
            [coords_steps appendPath:tmp_path];
            
        }
    }
    coords_y_tips = tips_array;
    //汇总路径
    [y_coord_path appendPath:arrows_path];
    [y_coord_path appendPath:coords_steps];
    //添加到图层
    CAShapeLayer *coordsLayer = [[CAShapeLayer alloc]init];
    coordsLayer.frame = _y_coord_View.bounds;
    coordsLayer.path = y_coord_path.CGPath;
    coordsLayer.lineWidth = 1.0f;
    coordsLayer.strokeColor = Coords_lineColor;
    coordsLayer.fillColor = [UIColor clearColor].CGColor;
    [_y_coord_View.layer addSublayer:coordsLayer];
    [self addSubview:_y_coord_View];
}


#pragma mark - 曲线与折线的算法
//画曲线
-(void)makecurveWithLabelWidth:(CGFloat)label_width{
    for (int i = 0; i < _coords_y_values.count; i++) {
        NSArray *values_arr = [_coords_y_values objectAtIndex:i];
        UIBezierPath *value_path = [UIBezierPath bezierPath];
        UIBezierPath *dots = [UIBezierPath bezierPath];
        NSMutableArray *points = [NSMutableArray array];
        [values_arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                
                CGFloat path_x = [_coords_x_values[idx] floatValue];//((float)idx + 0.5f) * (label_width + Coords_X_Lable_Space);
                
                CGFloat path_y = [obj floatValue];
                
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(path_x, path_y)]];
                //画点
                UIBezierPath *dot = [UIBezierPath bezierPath];
                [dot addArcWithCenter:CGPointMake(path_x, path_y) radius:Coords_Values_Line_Width/1.7f startAngle:0 endAngle:M_PI * 2 clockwise:NO];
                [dots appendPath:dot];
                
            }
        }];
        
        [value_path moveToPoint: [[points firstObject] CGPointValue]];
        [value_path addBezierThroughPoints:points];
        [value_path appendPath:dots];
        
        CAShapeLayer *value_layer = [[CAShapeLayer alloc]init];
        value_layer.frame = _draw_view.bounds;
        value_layer.path = value_path.CGPath;
        value_layer.lineWidth = Coords_Values_Line_Width;
        value_layer.strokeColor = [self.colorsArray objectAtIndex:i].CGColor;
        value_layer.fillColor = [UIColor clearColor].CGColor;
        //动画
        [self addAnimationToLayer:value_layer];
        [_draw_view.layer addSublayer:value_layer];
    }
}


//绘制折线图
-(void)makePolyLineWithLabelWidth:(CGFloat)label_width{
    for (int i = 0; i < _coords_y_values.count; i++) {
        @autoreleasepool {
            
            NSArray *values_arr = [_coords_y_values objectAtIndex:i];
            UIBezierPath *value_path = [UIBezierPath bezierPath];
            UIBezierPath *dots = [UIBezierPath bezierPath];
            [values_arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    CGFloat path_x = [_coords_x_values[idx] floatValue];;
                    CGFloat path_y = [obj floatValue];
                    //画点
                    UIBezierPath *dot = [UIBezierPath bezierPath];
                    [dot addArcWithCenter:CGPointMake(path_x, path_y) radius:Coords_Values_Line_Width/1.7f startAngle:0 endAngle:M_PI * 2 clockwise:NO];
                    if (idx == 0) {
                        [value_path moveToPoint:CGPointMake(path_x, path_y)];
                    }else{
                        [value_path addLineToPoint:CGPointMake(path_x, path_y)];
                    }
                    [dots appendPath:dot];
                }
            }];
            
            [value_path appendPath:dots];
            
            CAShapeLayer *value_layer = [[CAShapeLayer alloc]init];
            value_layer.frame = _draw_view.bounds;
            value_layer.path = value_path.CGPath;
            value_layer.lineWidth = Coords_Values_Line_Width;
            value_layer.strokeColor = [self.colorsArray objectAtIndex:i].CGColor;
            value_layer.fillColor = [UIColor clearColor].CGColor;
            value_layer.lineJoin = kCALineCapRound;
            [self addAnimationToLayer:value_layer];
            [_draw_view.layer addSublayer:value_layer];
            
        }
    }
}
#pragma  mark - 曲线图的辅助视图(图例)

/**
 *  添加图例的方法
 */
-(void)addLegend{
    
    if (_y_titles.count == 0 || _y_titles == nil) {
        return;
    }
    
    CGSize maxTitleSize = [self getSizeFromeMaxTitleWidth];
    CGFloat offset_space = 3; //label的间距
    maxTitleSize.height += offset_space;
    CGFloat legend_with = 30.0f; //图例的宽度
    CGFloat minLegendViewHeight = self.offset_top;//最小视图的高度
    CGFloat legend_W = maxTitleSize.width + legend_with + offset_space * 2;
    CGFloat legend_H = maxTitleSize.height * _y_titles.count;
    CGFloat legend_X = self.width - legend_W;
    CGFloat legend_Y = 0;
    CGFloat path_width = 2;
    if (legend_H < minLegendViewHeight) {
        legend_H = minLegendViewHeight;
        maxTitleSize.height = minLegendViewHeight * 1.0f / _y_titles.count;
    }
    //创建视图
    legendView = [[UIView alloc]initWithFrame:CGRectMake(legend_X, legend_Y, legend_W, legend_H)];
    legendView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    UIBezierPath *legendPath = [UIBezierPath bezierPath];
    for (int i = 0; i < _y_titles.count; i ++) {
        @autoreleasepool {
            UILabel *lab_tmp = [[UILabel alloc]init];
            lab_tmp.size = maxTitleSize;
            lab_tmp.x = offset_space;
            lab_tmp.y = i * maxTitleSize.height;
            lab_tmp.textAlignment = NSTextAlignmentCenter;
#warning 设置图例文本的颜色 set legend text colors
            lab_tmp.textColor = [UIColor grayColor];//self.colorsArray[i];
            lab_tmp.text = _y_titles[i];
            lab_tmp.font = [UIFont systemFontOfSize:Coords_Legend_Font_Size  weight:bold];
            UIBezierPath *tmp_path = [UIBezierPath bezierPath];
            UIBezierPath *dot_path = [UIBezierPath bezierPath];
            CGFloat path_minX = legend_W - 3;
            CGFloat path_maxX = maxTitleSize.width + 12;
            CGFloat path_Y = lab_tmp.centerY;
            CGFloat path_center = (path_maxX + path_minX)/2.0f;
            [tmp_path moveToPoint:CGPointMake(path_minX, path_Y)];
            [tmp_path addLineToPoint:CGPointMake(path_maxX, path_Y)];
            [dot_path addArcWithCenter:CGPointMake(path_center, path_Y) radius:path_width startAngle:0 endAngle:M_PI*2 clockwise:YES];
            [tmp_path appendPath:dot_path];
            [legendPath appendPath:tmp_path];
            [legendView addSubview:lab_tmp];
            //绘制线条
            CAShapeLayer *legendLayer = [[CAShapeLayer alloc]init];
            legendLayer.frame = CGRectMake(0, maxTitleSize.height * i, legendView.width - maxTitleSize.width, lab_tmp.height);
            legendLayer.path = legendPath.CGPath;
            legendLayer.lineCap = kCALineCapRound;
            legendLayer.lineWidth = path_width;
            legendLayer.strokeColor = self.colorsArray[i].CGColor;
            [legendView.layer addSublayer:legendLayer];
        }
    }
    legendView.layer.cornerRadius = 2;
    legendView.layer.borderWidth = 0.5;
    legendView.layer.borderColor = [UIColor grayColor].CGColor;
    legendView.layer.masksToBounds = YES;
    [self addSubview:legendView];
}


#pragma mark - 一些视图动画
/**
 *  为线条添加动画
 *
 *  @param layer CAShapeLayer
 */
-(void)addAnimationToLayer:(CAShapeLayer *)layer{
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    baseAnimation.fromValue = @0;
    baseAnimation.byValue = @0.3;
    baseAnimation.toValue = @1;
    baseAnimation.duration = 1.6;
    [layer addAnimation:baseAnimation forKey:nil];
}
#pragma  mark - 一些必要的工具
/**
 *  返回最小的Y值
 *
 *  @return 返回最大的Y
 */
-(CGFloat)getMinYValue{
    __block CGFloat min_tmp = MAXFLOAT;
    //遍历获取
    for (NSArray *array_tmp in _y_values) {
        
        [array_tmp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                CGFloat value_tmp = [obj floatValue];
                min_tmp = min_tmp < value_tmp ? min_tmp:value_tmp;
            }
        }];
        
    }
    return min_tmp;
}

/**
 *  返回最大的Y值
 *
 *  @return 返回最大的Y
 */
-(CGFloat)getMaxYValue{
    if (maxY == 0) {
        maxY = - MAXFLOAT;
    }
    __block CGFloat max_tmp = maxY;
    //遍历获取
    for (NSArray *array_tmp in _y_values) {
        
        [array_tmp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                CGFloat value_tmp = [obj floatValue];
                max_tmp = max_tmp > value_tmp ? max_tmp:value_tmp;
            }
        }];
        
    }
    return max_tmp;
}
/**
 *  根据Y轴的标题宽度获取最大值获取Size
 *
 *  @return size
 */
-(CGSize)getSizeFromeMaxTitleWidth{
    CGSize maxTitleSize = CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:Coords_Legend_Font_Size weight:bold];
    for (NSString *str in _y_titles) {
        @autoreleasepool {
            CGSize tmpSize = [str sizeWithAttributes:@{NSFontAttributeName:font}];
            if (tmpSize.width > maxTitleSize.width) {
                maxTitleSize = tmpSize;
            }
        }
    }
    return maxTitleSize;
}

/**
 *  获取x轴中最大的字符串size
 *
 *  @return size
 */
-(CGSize)getX_MaxLabelSize{
    
    CGSize label_size = CGSizeZero;
    
    for (NSString *str in _x_values) {
        CGSize size_tmp = [self getLabelWidthWithStr:str font:[UIFont systemFontOfSize:Coords_X_LableFont_Size]];
        if (size_tmp.width > label_size.width) {
            label_size = size_tmp;
        }
    }
    if (label_size.width < (_draw_view.width - self.offset_right - (_x_values.count * Coords_X_Lable_Space)) / (float)_x_values.count) {
        label_size.width = (_draw_view.width - self.offset_right - (_x_values.count * Coords_X_Lable_Space)) / (float)_x_values.count;
    }
    return label_size;
}
/**
 *  转换X值,符合视图坐标
 *
 *  @param label_width X轴的标签宽度
 */
-(void)swithXValuesWithLabelWidth:(CGFloat)label_width{
    NSMutableArray *x_vls = [NSMutableArray array];
    [_x_values enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat tmp = ((float)idx + 0.5f) * (label_width + Coords_X_Lable_Space);
        [x_vls addObject:@(tmp)];
    }];
    _coords_x_values = x_vls;
}
/**
 *  转换y值,符合视图坐标
 */
-(void)swithYValues{
    NSMutableArray *arrays = [NSMutableArray array];
    for (NSArray *y_values_tmp in _y_values) {
        NSMutableArray *tmp_arr = [NSMutableArray array];
        [y_values_tmp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool {
                CGFloat tmp_value = [obj floatValue] - self.minY;
                tmp_value = self.frame.size.height - tmp_value * _scale_Value - self.offset_bottom;
                [tmp_arr addObject:@(tmp_value)];
            }
        }];
        [arrays addObject:tmp_arr];
    }
    _coords_y_values = arrays;
}

/**
 *  是否能通过检查
 *
 *  @return 返回YES表示通过检查
 */
-(BOOL)PASS_checkErrors{
    //|| || self.y_values.count == 0
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        
        NSLog(@"frame 尺寸为空 : %@",NSStringFromCGRect(self.frame));
        return NO;
    }
    if (self.x_values.count == 0) {
        NSLog(@"x 坐标值为空 : %@",self.x_values);
        return NO;
    }
    if (self.y_values.count == 0) {
        
        NSLog(@"y 坐标值为空 : %@",self.y_values);
        return NO;
    }
    
    return YES;
}

/**
 *  根据字体大小获取字符串的尺寸
 *
 *  @param str  目标字符串
 *  @param font 字体
 *
 *  @return size
 */
-(CGSize)getLabelWidthWithStr:(NSString *)str font:(UIFont*)font{
    
    return [str sizeWithAttributes:@{NSFontAttributeName:font}];
    
}

#pragma mark -GET&SET方法重写
-(NSArray<UIColor *> *)colorsArray{
    
    if (!_colorsArray) {
        NSMutableArray *color_array = [[NSMutableArray alloc]init];
        for (int i = 0; i < _y_values.count; i ++) {
            UIColor *color = [UIColor colorWithRed:(arc4random_uniform(255)/255.0f) green:(arc4random_uniform(255)/255.0f) blue:(arc4random_uniform(255)/255.0f) alpha:1];
            [color_array addObject:color];
        }
        _colorsArray = color_array;
    }
    return _colorsArray;
}

#pragma mark - 设置刻度的个数
- (void)setCoords_Y_Tips:(NSInteger)tipCont{
    
    Coords_Y_Tip = tipCont;
}

#pragma mark - 设置最小的 Y 值
- (void)setMinY:(CGFloat)minValue{
    if (minValue < 0) {
        minValue = [self getMinYValue];
    }
    if (minValue > [self getMaxYValue]) {
        minValue = [self getMaxYValue] - (Coords_Y_Tip + 1) / 10.0f;
    }
    _minY = minValue;
    if (isCustemY) {
        [self setXCoordinatesLocationInYValue:_x_coord_location];
    }
}

- (void)setXCoordinatesLocationInYValue:(CGFloat)yValue{
    
    isCustemY = YES;
    
    if (yValue < self.minY) {
        
        yValue = self.minY;
        
    }
    if (yValue > [self getMaxYValue]) {
        yValue = [self getMaxYValue];
    }
    
    _x_coord_location = yValue;
    
}

#pragma mark - 点击事件的代理方法(数值显示)
-(void)WMChartViewTouchPoint:(CGPoint)point{
    
    CGFloat x_touch_space = _coords_x_label_width / 2.0f;
    __block NSInteger x_idx = -1;
    __block NSInteger y_idx = -1;
    [_coords_x_values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat x_vls = [obj floatValue];
        CGFloat distance = MAX(x_vls, point.x) - MIN(x_vls, point.x);//ABS(x_vls - point.x);
        if (distance < x_touch_space) {
            x_idx = idx;
        }
    }];
    
    __block CGFloat distance = MAXFLOAT;
    for (int i = 0; i < _coords_y_values.count; i ++) {
        
        NSArray *y_vls = _coords_y_values[i];
        
        if (y_vls.count - 1 >= x_idx && x_idx != -1) {
            CGFloat dis = ABS_VALUE(point.y,[y_vls[x_idx] floatValue]);
            if (distance > dis) {
                y_idx = i;
                distance = dis;
            }
        }
    }
    if (y_idx < 0 || x_idx<0) {
        return;
    }
    NSMutableString *info = [NSMutableString string];
    NSString *valueStr = _y_values[y_idx][x_idx];
    for (int i = 0 ; i < _y_values.count; i ++) {
        if ([_y_values[i][x_idx] isEqualToString:valueStr]) {
            if (![info isEqualToString:@""]) {
                [info appendString:@"\n"];
            }
            if (_y_titles.count > i) {
                [info appendString:_y_titles[i]];
                [info appendString:@"\n"];
            }
            [info appendString:[NSString stringWithFormat:@"%@:%@",_x_values[x_idx],_y_values[i][x_idx]]];
        }
    }
    
    CGPoint showPoint = CGPointMake([_coords_x_values[x_idx] floatValue], [_coords_y_values[y_idx][x_idx] floatValue]);
//    PopoverView *popView = [PopoverView new];
//    [popView showAtPoint:showPoint inView:_draw_view withText:info];

}

#pragma mark - 触摸可移动图例
BOOL isMove;
CGPoint legend_point;
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    isMove = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(legendView.frame, point)) {
        legend_point = [touch locationInView:legendView];
        isMove = YES;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if (!isMove) {
        return;
    }
    @autoreleasepool {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        //转化成相对的中心
        point.x += legendView.width/2.0f - legend_point.x;
        point.y += legendView.height/2.0f - legend_point.y;
        
        if (point.x < legendView.width / 2.0f) {
            point.x = legendView.width / 2.0f;
        }
        if (point.y < legendView.height / 2.0f) {
            point.y = legendView.height / 2.0f;
        }
        
        if (point.x > self.width - legendView.width / 2.0f) {
            point.x = self.width - legendView.width / 2.0f;
        }
        if (point.y > self.height - legendView.height / 2.0f) {
            point.y = self.height - legendView.height / 2.0f;
        }
        
        
        legendView.center = point;
    }
}


@end


