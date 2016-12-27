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

    UIWindow *w = [UIApplication sharedApplication].windows[0];
    self.floatWindow = [[WMAssistantBall alloc] initWithWindow:w];
//    self.view.backgroundColor = [UIColor lightGrayColor];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
