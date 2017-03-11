//
//  WMAssistantInfoController.m
//  Pods
//
//  Created by roronoa on 2017/3/11.
//
//

#import "WMAssistantInfoController.h"
#import "WMChartLine.h"

@interface WMAssistantInfoController () {

    WMChartLine *v;
}

@property (nonatomic, strong) NSMutableArray *x_vls;        //x轴
@property (nonatomic, strong) NSMutableArray *y_vls;        //y

@end

@implementation WMAssistantInfoController

- (void)viewDidLoad {
    [super viewDidLoad];//创建折线图

    self.view.backgroundColor = [UIColor whiteColor];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm:ss";

    self.x_vls = [NSMutableArray new];
    self.y_vls = [NSMutableArray new];

    //日期对应数据
    for (int i =0; i<self.records.count; i++) {
        NSDictionary *dict = self.records[i];
//        NSString *xText = [formatter stringFromDate:dict[@"date"]];
        [self.x_vls addObject:@(i).stringValue];

        NSString *yText = [dict[@"value"] stringValue];
        [self.y_vls addObject:yText];
    }




    v = [[WMChartLine alloc]initWithFrame:self.view.bounds];
    //折线名称
    v.y_titles = @[self.title];
    // x轴坐标数组
    v.x_values = self.x_vls;
    // y轴坐标数组
    v.y_values = @[self.y_vls];

    [v setXCoordinatesLocationInYValue:0];
    [v setCoordPlusAndMinusSymmetryShowZeroPoint:NO];
    [self.view addSubview:v];

    [v startDrawWithLineType:WMChartLineTypeCurve];
}


@end
