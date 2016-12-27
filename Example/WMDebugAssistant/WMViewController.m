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
@property (strong, nonatomic) WMAssistantBall *floatWindow;

@end

@implementation WMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.floatWindow = [[WMAssistantBall alloc] init];
    self.floatWindow.addtionItems = @[@"暗门", @"接口数", @"网络", @"日志"];
    [self.floatWindow doWork];
    

    self.floatWindow.selectBlock = ^(NSString *title, UIButton *button) {
        NSLog(@"%@", title);
        [button setTitle:@"123" forState:UIControlStateNormal];
    };
//    self.view.backgroundColor = [UIColor lightGrayColor];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
