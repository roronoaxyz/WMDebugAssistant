//
//  WMAssistantBall.m
//  testTab
//
//  Created by thomas on 16/7/29.
//  Copyright © 2017年 thomas. All rights reserved.
//

#import "WMAssistantBall.h"/** 监控助手 **/
#import "UIImage+WM.h"          //图片扩展
#import "WMCpuHelper.h"             //CPU
#import "WMMemeryHelper.h"              //内存
#import "WMNetworkFlow.h"           //流量
#import "WMFpsHelper.h"            //fps
#import "WMAssistantController.h"       //空界面  window 用
#import "WMAssistantNavigationController.h" //导航条 横屏
#import "WMAssistantInfoController.h"           //报表界面


#define WMWS(weakSelf)  __weak __typeof(&*self)weakSelf = self;/** 弱引用自己 */
#define kWMBallCount        (self.itemArray.count / 2)
#define kWMThisWidth CGRectGetWidth(self.frame)
#define kWMThisHeight CGRectGetHeight(self.frame)
#define kWMWindowWidth CGRectGetWidth(self.window.frame)
#define kWMWindowHeight CGRectGetHeight(self.window.frame)

@interface WMAssistantBall()

@property (nonatomic, assign) UIWindow *window;
@property (nonatomic, assign) NSInteger bWidth;           //球大小
@property (nonatomic, assign) BOOL  isShowTab;
@property (nonatomic, strong) NSArray *itemArray;     //
@property (nonatomic, strong) UIPanGestureRecognizer *pan;//移动
@property (nonatomic, strong) UITapGestureRecognizer *tap;//点击
@property (nonatomic, strong) UIButton *mainImageButton;    //点击的小球
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAAnimationGroup *animationGroup;
@property (nonatomic, strong) CAShapeLayer *circleShape;

@property (nonatomic, strong) WMCpuHelper *cpuHelper;       //cpu
@property (nonatomic, strong) WMMemeryHelper *memHelper;       //内存
@property (nonatomic, strong) WMNetworkFlow *networkFlow;       //流量
@property (nonatomic, strong) WMFpsHelper *fpsHelper;       //fps


@end

@implementation WMAssistantBall
//
- (id)init {
    CGFloat sWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sHeight = [UIScreen mainScreen].bounds.size.height;

    CGRect frame = CGRectMake(sWidth - 25, sHeight / 5, 50, 50);
    if(self = [super initWithFrame:frame]) {
        UIWindow *w = [UIApplication sharedApplication].windows[0];
        self.window = w;
        self.bWidth = 50;
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;  //如果想在 alert 之上，则改成 + 2
        self.rootViewController = [WMAssistantController new];
        [self makeKeyAndVisible];

        //设备旋转的时候收回按钮
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc {

}

#pragma mark  ------- contentview ----------
- (void)loadContentView {
    self.contentView = [[UIView alloc] initWithFrame:(CGRect){self.bWidth ,0, kWMBallCount * (self.bWidth + 5),self.bWidth}];
    self.contentView.alpha  = 0;
    [self addSubview:self.contentView];
}

#pragma mark  ------- 主按钮 ----------
- (void)loadMainButton {
    if (!self.ballColor) {
        self.ballColor = [UIColor whiteColor];
    }

    UIImage *nImage = [UIImage wm_imageWithColor:self.ballColor withFrame:CGRectMake(0, 0, self.bWidth, self.bWidth)];
//    nImage = [nImage wm_roundCorner];

    self.mainImageButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainImageButton setFrame:(CGRect){0, 0, self.bWidth, self.bWidth}];
    [self.mainImageButton setImage:nImage forState:UIControlStateNormal];
    self.mainImageButton.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.mainImageButton.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.mainImageButton.layer.shadowOpacity = 1;//阴影透明度，默认0
    self.mainImageButton.layer.shadowRadius = 3;//阴影半径，默认3
//    [self.mainImageButton setImage:hImage forState:UIControlStateHighlighted];
    [self.mainImageButton addTarget:self action:@selector(doTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainImageButton addTarget:self action:@selector(mainBtnTouchDown) forControlEvents:UIControlEventTouchDown];
    self.mainImageButton.layer.masksToBounds = YES;
    self.mainImageButton.layer.cornerRadius = self.bWidth / 2;
    
    [self addSubview:self.mainImageButton];
}

- (void)mainBtnTouchDown{
    if (!self.isShowTab) {
        [self performSelector:@selector(buttonAnimation) withObject:nil afterDelay:0.5];
    }
}

#pragma mark  ------- 手势 ----------
- (void)loadGesture {
    _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doPan:)];
    _pan.delaysTouchesBegan = NO;
    [self addGestureRecognizer:_pan];
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    [self addGestureRecognizer:_tap];
}

//改变位置
- (void)doPan:(UIPanGestureRecognizer*)p {
    CGPoint panPoint = [p locationInView:self.window];

    if(p.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        [self stopAnimation];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:3.0];

        if(panPoint.x <= kWMWindowWidth/2)
        {
            if(panPoint.y <= 40+kWMThisHeight/2 && panPoint.x >= 20+kWMThisWidth/2)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(panPoint.x, kWMThisHeight/2);
                }];
            }
            else if(panPoint.y >= kWMWindowHeight-kWMThisHeight/2-40 && panPoint.x >= 20+kWMThisWidth/2)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(panPoint.x, kWMWindowHeight-kWMThisHeight/2);
                }];
            }
            else if (panPoint.x < kWMThisWidth/2+20 && panPoint.y > kWMWindowHeight-kWMThisHeight/2)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(kWMThisWidth/2, kWMWindowHeight-kWMThisHeight/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y < kWMThisHeight/2 ? kWMThisHeight/2 :panPoint.y;
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(kWMThisWidth/2, pointy);
                }];
            }
        }
        else if(panPoint.x > kWMWindowWidth/2)
        {
            if(panPoint.y <= 40+kWMThisHeight/2 && panPoint.x < kWMWindowWidth-kWMThisWidth/2-20 )
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(panPoint.x, kWMThisHeight/2);
                }];
            }
            else if(panPoint.y >= kWMWindowHeight-40-kWMThisHeight/2 && panPoint.x < kWMWindowWidth-kWMThisWidth/2-20)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(panPoint.x, kWMWindowHeight-kWMThisHeight/2);
                }];
            }
            else if (panPoint.x > kWMWindowWidth-kWMThisWidth/2-20 && panPoint.y < kWMThisHeight/2)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(kWMWindowWidth-kWMThisWidth/2, kWMThisHeight/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y > kWMWindowHeight-kWMThisHeight/2 ? kWMWindowHeight-kWMThisHeight/2 :panPoint.y;
                [UIView animateWithDuration:0.3 animations:^{
                    self.center = CGPointMake(kWMWindowWidth-kWMThisWidth/2, pointy);
                }];
            }
        }
    }
}
//点击事件
- (void)doTap:(UITapGestureRecognizer*)p
{
    [self stopAnimation];

    //拉出悬浮窗
    if (self.center.x == 0) {
        self.center = CGPointMake(kWMThisWidth/2, self.center.y);
    }else if (self.center.x == kWMWindowWidth) {
        self.center = CGPointMake(kWMWindowWidth - kWMThisWidth/2, self.center.y);
    }else if (self.center.y == 0) {
        self.center = CGPointMake(self.center.x, kWMThisHeight/2);
    }else if (self.center.y == kWMWindowHeight) {
        self.center = CGPointMake(self.center.x, kWMWindowHeight - kWMThisHeight/2);
    }


    CGFloat iWidth= (self.bWidth + 5.0f);//每一个item 的宽度
    CGFloat thisX = CGRectGetMinX(self.frame);      //self.x
    CGFloat thisY = CGRectGetMinY(self.frame);      //self.y


    //展示按钮列表
    if (!self.isShowTab) {
        self.isShowTab = TRUE;

        //为了主按钮点击动画
        self.layer.masksToBounds = YES;

        [UIView animateWithDuration:0.1 animations:^{

            self.contentView.alpha  = 1;

            CGFloat sWidth = (kWMThisWidth + kWMBallCount * iWidth);
            CGFloat sHeight = self.bWidth * 2;

            if (thisX <= kWMWindowWidth/2) {
                self.frame = CGRectMake(thisX, thisY, sWidth, sHeight);
                self.contentView.frame = (CGRect){iWidth, 0, sWidth - iWidth, sHeight};
            }else{
                CGFloat sLeft = thisX  - kWMBallCount * iWidth;

                self.frame = CGRectMake(sLeft, thisY,  sWidth, sHeight);
                self.mainImageButton.frame = CGRectMake((kWMBallCount * iWidth), 0, self.bWidth, self.bWidth);
                self.contentView.frame = (CGRect){10.0f, 0 , sWidth - self.bWidth, sHeight};
            }
            self.backgroundColor = [UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:0.5];
        }];

        //移除pan手势
        if (_pan) {
            [self removeGestureRecognizer:_pan];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
    }else{
        self.isShowTab = FALSE;

        //为了主按钮点击动画
        self.layer.masksToBounds = NO;

        //添加pan手势
        if (_pan) {
            [self addGestureRecognizer:_pan];
        }

        [UIView animateWithDuration:0.1 animations:^{

            self.contentView.alpha  = 0;

            if (thisX + CGRectGetMinX(self.mainImageButton.frame) <= kWMWindowWidth/2) {
                self.frame = CGRectMake(thisX, thisY, self.bWidth ,self.bWidth);
            }else{
                self.mainImageButton.frame = CGRectMake(0, 0, self.bWidth, self.bWidth);
                self.frame = CGRectMake(thisX + kWMBallCount * iWidth, thisY, self.bWidth ,self.bWidth);
            }
            self.backgroundColor = [UIColor clearColor];
        }];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:3.0];
    }
}



#pragma mark  ------- cpu ----------
- (void)loadCpu {
    //
    self.cpuHelper = [[WMCpuHelper alloc] init];
}

- (void)doDisplayCpu:(CGFloat)cpuUsage {
    UIButton *cpuBUtton = [self.contentView viewWithTag:0x999];
    NSString *cpuString = [NSString stringWithFormat:@"%.2f%%", cpuUsage];
    [cpuBUtton setTitle:cpuString forState:UIControlStateNormal];
}

#pragma mark  ------- 内存 ----------
- (void)loadMemery {
    //
    self.memHelper = [[WMMemeryHelper alloc] init];
}

- (void)doDisplayMemory:(CGFloat)usedMemory {
    UIButton *memeryButton = [self.contentView viewWithTag:0x999 + 1];
    NSString *memString = [NSString stringWithFormat:@"%.2fMB", usedMemory];
    [memeryButton setTitle:memString forState:UIControlStateNormal];
}


#pragma mark  ------- 网速 ----------
- (void)loadFlow {
    //
    self.networkFlow = [[WMNetworkFlow alloc] init];
}

- (void)doDisplayNet:(u_int32_t)sendFlow receivedFlow:(u_int32_t)receivedFlow {
    UIButton *flowButton = [self.contentView viewWithTag:0x999 + 2];
    NSString *flowString = [NSString stringWithFormat:@"%.2fkb/s", receivedFlow / 1024.0f];
    [flowButton setTitle:flowString forState:UIControlStateNormal];
}

#pragma mark  ------- fps ----------
- (void)loadFps {
    //
    self.fpsHelper = [[WMFpsHelper alloc] init];
}

- (void)doDisplayfps:(CGFloat)fps {
    UIButton *fpsButton = [self.contentView viewWithTag:0x999 + 3];
    NSString *fpsString = [NSString stringWithFormat:@"%.0ffps", fps];
    [fpsButton setTitle:fpsString forState:UIControlStateNormal];

}

#pragma mark  ------- 按钮 ----------
- (UIButton *)customButton:(NSInteger)index image:(UIImage *)image title:(NSString *)title {
    CGFloat top = (index % 2 == 0) ? 0 : self.bWidth;
    CGFloat left = (index / 2) * self.bWidth;
    
    UIButton *bbb = [UIButton buttonWithType:UIButtonTypeCustom];
    bbb.tag = index + 0x999;
    [bbb setFrame: CGRectMake(left, top, self.bWidth , self.bWidth)];
    [bbb setBackgroundColor:[UIColor clearColor]];
    [bbb setTitle:title forState:UIControlStateNormal];
    bbb.titleLabel.font = [UIFont systemFontOfSize:12];
    bbb.titleLabel.adjustsFontSizeToFitWidth = YES;
    [bbb addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];// 点击操作

    if (image) {
        [bbb setImage:image forState:UIControlStateNormal];
        [bbb wm_titleUnderIcon:5];
    }
    
    return bbb;
}

- (void)setButtons{
    self.itemArray = @[@"CPU",@"内存", @"流量",@"FPS"];
    if (self.addtionItems.count <= 6) {
        self.itemArray = [self.itemArray arrayByAddingObjectsFromArray:self.addtionItems];
    }

    NSArray *colorArray = @[[UIColor whiteColor],
                            [UIColor redColor],
                            [UIColor greenColor],
                            [UIColor blueColor],
                            [UIColor cyanColor],
                            [UIColor yellowColor],
                            [UIColor magentaColor],
                            [UIColor orangeColor],
                            [UIColor purpleColor],
                            [UIColor brownColor],
                            ];
    for (int i=0; i<self.itemArray.count; i++) {
        NSString *title = self.itemArray[i];

        UIImage *nImage = [UIImage wm_imageWithColor:colorArray[i] withFrame:CGRectMake(0, 0, 18, 18)];
        nImage = [nImage wm_roundCorner];
        
        UIButton *button = [self customButton:i image:nImage title:title];
        [self.contentView addSubview:button];
    }
}

//点击事件
- (void)itemsClick:(id)sender {

    UIButton *button = (UIButton *)sender;
    NSInteger t = button.tag - 0x999;

    NSString *title = self.itemArray[t];
    BOOL flag = YES;

    WMWS(__self)

    if ([title isEqualToString:@"CPU"]) {
        if (![self.cpuHelper isActived]) {
            flag = NO;
            [self.cpuHelper startblock:^(CGFloat cpuUsage) {
                [__self doDisplayCpu:cpuUsage];
            }];
        }
    }
    else if ([title isEqualToString:@"内存"]) {
        if (![self.memHelper isActived]) {
            flag = NO;
            [self.memHelper startblock:^(CGFloat usedMemory) {
                [__self doDisplayMemory:usedMemory];
            }];
        }

    }
    else if ([title isEqualToString:@"流量"]) {
        if (![self.networkFlow isActived]) {
            flag = NO;
            [self.networkFlow startblock:^(u_int32_t sendFlow, u_int32_t receivedFlow) {
                [__self doDisplayNet:sendFlow receivedFlow:receivedFlow];
            }];
        }

    }
    else if ([title isEqualToString:@"FPS"]) {
        if (![self.fpsHelper isActived]) {
            flag = NO;
            [self.fpsHelper startblock:^(CGFloat fps) {
                [__self doDisplayfps:fps];
            }];
        }
    }

    if (flag) {
        if (self.isShowTab){
            [self doTap:nil];
        }

        if (self.selectBlock) {
            self.selectBlock(title, button);
        }
    }

}

#pragma mark  ------- 绘图操作 ----------
- (void)drawRect:(CGRect)rect {
    [self drawDash];
}

//分割线
- (void)drawDash{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGFloat lengths[] = {2,1};
    CGContextSetLineDash(context, 0, lengths,2);
    for (int i = 1; i < kWMBallCount; i++){
        CGContextMoveToPoint(context, CGRectGetMinX(self.contentView.frame) + i * self.bWidth, 5.0f * 2);
        CGContextAddLineToPoint(context, CGRectGetMinX(self.contentView.frame) + i * self.bWidth, self.bWidth - 5.0f * 2);
    }
    CGContextStrokePath(context);
}

- (void)changeStatus
{
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+kWMThisWidth/2 ? 0 :  self.center.x > kWMWindowWidth - 20 -kWMThisWidth/2 ? kWMWindowWidth : self.center.x;
        CGFloat y = self.center.y < 40 + kWMThisHeight/2 ? 0 : self.center.y > kWMWindowHeight - 40 - kWMThisHeight/2 ? kWMWindowHeight : self.center.y;
        
        //禁止停留在4个角
        if((x == 0 && y ==0) || (x == kWMWindowWidth && y == 0) || (x == 0 && y == kWMWindowHeight) || (x == kWMWindowWidth && y == kWMWindowHeight)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}

- (void)doBorderWidth{
    self.layer.cornerRadius = self.bWidth / 2;
    self.layer.borderWidth = (1/[UIScreen mainScreen].scale);
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

#pragma mark  ------- animation -------------

- (void)buttonAnimation{

    self.layer.masksToBounds = NO;
    
    CGFloat scale = 1.0f;
    
    CGFloat width = CGRectGetWidth(self.mainImageButton.frame), height = CGRectGetHeight(self.mainImageButton.frame);

    CGFloat biggerEdge = width > height ? width : height, smallerEdge = width > height ? height : width;
    CGFloat radius = smallerEdge / 2 > 20.0f ? 20.0f : smallerEdge / 2;
    
    scale = biggerEdge / radius + 0.5;
    _circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
                                                 pathRect:CGRectMake(0, 0, radius * 2, radius * 2)
                                                   radius:radius];

// 圆圈放大效果
//        scale = 2.5f;
//        _circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
//                                                 pathRect:CGRectMake(-CGRectGetMidX(self.mainImageButton.bounds), -CGRectGetMidY(self.mainImageButton.bounds), width, height)
//                                                   radius:self.mainImageButton.layer.cornerRadius];
   
    
    [self.mainImageButton.layer addSublayer:_circleShape];
    
    CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:1.0f];
    
    [_circleShape addAnimation:groupAnimation forKey:nil];
}

- (void)stopAnimation{
  
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(buttonAnimation) object:nil];
    
    if (_circleShape) {
        [_circleShape removeFromSuperlayer];
    }
}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius
{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    

    if (!self.shapeColor) {
        self.shapeColor = [UIColor lightGrayColor];
    }
    circleShape.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    circleShape.fillColor = self.shapeColor.CGColor;

//  圆圈放大效果
//  circleShape.fillColor = [UIColor clearColor].CGColor;
//  circleShape.strokeColor = [UIColor purpleColor].CGColor;

    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    _animationGroup = [CAAnimationGroup animation];
    _animationGroup.animations = @[scaleAnimation, alphaAnimation];
    _animationGroup.duration = duration;
    _animationGroup.repeatCount = INFINITY;
    _animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return _animationGroup;
}


- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark  ------- 事件 ---------
/** 显示 在属性配置完成之后 **/
/** 只能调用一次 后面几次不会生效 **/
- (void)doWork {
    if (self.tag == 0x99) {
        return;
    }
    self.tag = 0x99;

    //内容
    [self loadContentView];

    //主按钮
    [self loadMainButton];

    //添加按钮
    [self setButtons];

    //手势
    [self loadGesture];

    //cpu
    [self loadCpu];

    //内存
    [self loadMemery];

    //下载
    [self loadFlow];

    //fps
    [self loadFps];

    //描边
    [self doBorderWidth];
}

/** 通过标题获取按钮 默认的4个是 @"CPU",@"内存", @"流量",@"FPS" **/
- (UIButton *)buttonOfTitle:(NSString *)title {
    NSInteger index = [self.itemArray indexOfObject:title];
    if (index != NSNotFound) {
        UIButton *button = [self.contentView viewWithTag:0x999 + index];
        return button;
    }
    return nil;
}

//生成一张报表 类型   1 cpu ;2 内存 ; 3 网速
- (void)makeChart:(NSInteger)flag pCtrl:(UIViewController *)pCtrl {
    WMAssistantInfoController *aCtrl = [[WMAssistantInfoController alloc] init];
    if (flag == 1) {
        aCtrl.title = @"CPU";
        aCtrl.records = [self.cpuHelper getRecords];
        aCtrl.unit = @"%";
    }
    else if (flag == 2) {
        aCtrl.title = @"内存";
        aCtrl.records = [self.memHelper getRecords];
        aCtrl.unit = @"MB";
    }
    else if (flag == 3) {
        aCtrl.title = @"流量";
        aCtrl.records = [self.networkFlow getRecords];
        aCtrl.unit = @"kb/s";
    }
    //
    WMAssistantNavigationController *nCtrl = [[WMAssistantNavigationController alloc] initWithRootViewController:aCtrl];
    [pCtrl presentViewController:nCtrl animated:YES completion:nil];
}

#pragma mark  ------- 设备旋转 -----------
- (void)orientChange:(NSNotification *)notification{
    //不设置的话,长按动画那块有问题
    self.layer.masksToBounds = YES;
    
    //旋转前要先改变frame，否则坐标有问题（临时办法）
    CGFloat sWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(sWidth - 25, sHeight / 5, 50, 50);
    self.frame = frame;
    
    if (self.isShowTab) {
        [self doTap:nil];
    }
}

@end
