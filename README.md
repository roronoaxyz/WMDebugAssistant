# WMDebugAssistant

[![CI Status](http://img.shields.io/travis/Thomas/WMDebugAssistant.svg?style=flat)](https://travis-ci.org/Thomas/WMDebugAssistant)
[![Version](https://img.shields.io/cocoapods/v/WMDebugAssistant.svg?style=flat)](http://cocoapods.org/pods/WMDebugAssistant)
[![License](https://img.shields.io/cocoapods/l/WMDebugAssistant.svg?style=flat)](http://cocoapods.org/pods/WMDebugAssistant)
[![Platform](https://img.shields.io/cocoapods/p/WMDebugAssistant.svg?style=flat)](http://cocoapods.org/pods/WMDebugAssistant)

## pod使用
pod 'WMDebugAssistant' ,:git=>"https://github.com/roronoaxyz/WMDebugAssistant.git", :tag => '0.1.2'

## iOS代码
    @property (strong, nonatomic) WMAssistantBall *assistantBall;

    self.assistantBall = [[WMAssistantBall alloc] init];//一定要作为一个局部属性
    self.assistantBall.addtionItems = @[@"暗门", @"接口数", @"网络", @"日志"];     //额外加一些按钮
    self.assistantBall.ballColor = [UIColor blueColor];       //按钮颜色
    self.assistantBall.shapeColor = [UIColor redColor];           //移动时的光圈颜色
    [self.assistantBall doWork];              //很重要 一定要调用

    //点击了某一个选项
    self.assistantBall.selectBlock = ^(NSString *title, UIButton *button) {
        NSLog(@"%@", title);
    };

## Author

Thomas, roronoa@foxmail.com

## License

WMDebugAssistant is available under the MIT license. See the LICENSE file for more info.
