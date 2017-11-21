//
//  WMPrintLogController.m
//  Pods
//
//  Created by roronoa on 2017/11/21.
//

#import "WMPrintLogController.h"

@interface WMPrintLogController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation WMPrintLogController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.font = [UIFont systemFontOfSize:12];
    self.textView.text = self.text;
    [self.view addSubview:self.textView];
}


@end
