//
//  WMAssistantInfoController.h
//  Pods
//
//  Created by roronoa on 2017/3/11.
//
//

#import <UIKit/UIKit.h>

/** 报表界面 外部不要直接引用 **/
@interface WMAssistantInfoController : UIViewController

@property (nonatomic, strong) NSString *title;            //标题名字
@property (nonatomic, strong) NSString *unit;            //单位
@property (nonatomic, strong) NSArray *records;     //记录

@end
