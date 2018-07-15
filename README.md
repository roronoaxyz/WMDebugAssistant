# WMDebugAssistant
 ![image](https://github.com/roronoaxyz/WMDebugAssistant/blob/master/Example/Shot/assistant.gif)

## 作用
    在自己的应用中，实时监测CPU，内存，网络下载，fps的状态，帮助开发定位。
    等于XCode 调试时候的 debeg 功能，但是能在发布时候使用。
    有效定位 手机发烫，内存泄露，浪费流量，界面卡顿等问题。
    
 ![image](https://github.com/roronoaxyz/WMDebugAssistant/blob/master/Example/assistant.gif)

## pod使用
pod 'WMDebugAssistant' ,:git=>"https://github.com/roronoaxyz/WMDebugAssistant.git", :tag => '0.2.3'


悬浮球 添加在第一个界面生成后  因为它本身是个 UIWindow

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
    
    //历史数据曲线图
    [self.assistantBall makeChart:1 pCtrl:self];

## Author

Thomas, roronoa@foxmail.com

## License

WMDebugAssistant is available under the MIT license. See the LICENSE file for more info.
