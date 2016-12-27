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

@end

@implementation WMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//@property (strong, nonatomic) WMAssistantBall *assistantBall;
    self.assistantBall = [[WMAssistantBall alloc] init];//一定要作为一个局部属性
    self.assistantBall.addtionItems = @[@"暗门", @"接口数", @"网络", @"日志"];     //额外加一些按钮
    self.assistantBall.ballColor = [UIColor blueColor];       //按钮颜色
    self.assistantBall.shapeColor = [UIColor redColor];           //移动时的光圈颜色
    [self.assistantBall doWork];              //很重要 一定要调用

    //点击了某一个选项
    self.assistantBall.selectBlock = ^(NSString *title, UIButton *button) {
        NSLog(@"%@", title);
//        [button setTitle:@"123" forState:UIControlStateNormal];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
