//
//  WMViewController.m
//  WMDebugAssistant
//
//  Created by Thomas on 12/27/2016.
//  Copyright (c) 2016 Thomas. All rights reserved.
//

#import "WMViewController.h"
#import "WMAssistantBall.h"/** 监控助手 **/

@interface WMViewController ()
@property (strong, nonatomic) WMAssistantBall *assistantBall;
@property (assign, nonatomic) BOOL isObserverIng;       //正在监测

@end

@implementation WMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"open" style:UIBarButtonItemStylePlain target:self action:@selector(open:)];


//@property (strong, nonatomic) WMAssistantBall *assistantBall;
    self.assistantBall = [[WMAssistantBall alloc] init];//一定要作为一个局部属性
    self.assistantBall.addtionItems = @[@"暗门", @"接口数", @"日志"];     //额外加一些按钮
    self.assistantBall.ballColor = [UIColor blueColor];       //按钮颜色
    self.assistantBall.shapeColor = [UIColor redColor];           //移动时的光圈颜色
    [self.assistantBall doWork];              //很重要 一定要调用

    __weak typeof(self) __self = self;
    //点击了某一个选项
    self.assistantBall.selectBlock = ^(NSString *title, UIButton *button) {
        NSLog(@"%@", title);
        [__self doSelect:title];

    };
}

- (void)doSelect:(NSString *)title {
    if ([title isEqualToString:@"CPU"]) {
        [self.assistantBall makeChart:1 pCtrl:self];
    }
    else if ([title isEqualToString:@"内存"]) {
        [self.assistantBall makeChart:2 pCtrl:self];
    }
    else if ([title isEqualToString:@"下载"]) {
        [self.assistantBall makeChart:3 pCtrl:self];
    }
    else if ([title isEqualToString:@"上传"]) {
        [self.assistantBall makeChart:4 pCtrl:self];
    }
}

- (void)open:(id)sender {
    if (!self.isObserverIng) {
        self.isObserverIng = YES;
        [self.assistantBall startObserver];              //
    }
    else {
        self.isObserverIng = NO;
        [self.assistantBall stopObserver];              //
    }
}

@end
