//
//  WMAssistantInfoController.m
//  Pods
//
//  Created by roronoa on 2017/3/11.
//
//

#import "WMAssistantInfoController.h"
#import "WMLineChartView.h"

#define WMWS(weakSelf)  __weak __typeof(&*self)weakSelf = self;/** 弱引用自己 */

@interface WMAssistantInfoController () {

    UIButton *dButton;
    UILabel *pointLbl; //点击的标签
    WMLineChartView *lineChartView;
}

@property (nonatomic, strong) NSMutableArray *x_vls;        //x轴
@property (nonatomic, strong) NSMutableArray *y_vls;        //y

@end

@implementation WMAssistantInfoController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];

    [self chartDidLoad];
    [self dismissDidLoad];
}

- (void)dismissDidLoad {
    dButton = [UIButton new];
    dButton.frame = CGRectMake(0, 0, 56, 32);
    [dButton setTitle:@"返回" forState:UIControlStateNormal];
    [dButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
    dButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [dButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dButton];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}


- (void)chartDidLoad {

    self.x_vls = [NSMutableArray new];
    self.y_vls = [NSMutableArray new];

    CGFloat maxY = 0;

    //日期对应数据
    for (int i =0; i<self.records.count; i++) {
        NSDictionary *dict = self.records[i];

        [self.x_vls addObject:@(i).stringValue];

        CGFloat value = [dict[@"value"] floatValue];
        if (value > maxY) {
            maxY = value;
        }

        NSString *yText = [dict[@"value"] stringValue];
        [self.y_vls addObject:yText];
    }

    lineChartView = [[WMLineChartView alloc] initWithFrame:self.view.bounds xTitleArray:self.x_vls yValueArray:self.y_vls yMax:maxY yMin:0.0 unit:self.unit];
    [self.view addSubview:lineChartView];


}

@end
