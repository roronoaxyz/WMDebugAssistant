//
//  WMDataBaseTableController.h
//  ELDebug
//
//  Created by roronoa on 2017/9/30.
//  Copyright © 2017年 roronoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB.h"

//数据库列表数据
@interface WMDataBaseTableController : UITableViewController
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSString *tableName;
@end
