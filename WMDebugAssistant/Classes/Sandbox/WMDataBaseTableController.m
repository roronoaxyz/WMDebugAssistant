//
//  WMDataBaseTableController.m
//  ELDebug
//
//  Created by roronoa on 2017/9/30.
//  Copyright © 2017年 roronoa. All rights reserved.
//

#import "WMDataBaseTableController.h"
#import "WMPrintLogController.h"
#import "FMDB.h"

@interface WMDataBaseTableController ()
@property (nonatomic, strong) NSMutableArray *listArray;
@end

@implementation WMDataBaseTableController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.listArray = [NSMutableArray new];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DATABASE_CELL"];
    self.tableView.tableFooterView = [UIView new];

    if ([self.db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", self.tableName];
        FMResultSet *resultSet = [self.db executeQuery:sql];
        while ([resultSet next]) {
            NSDictionary *resultDictionary = [resultSet resultDictionary];
            [self.listArray addObject:resultDictionary];
        }
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DATABASE_CELL" forIndexPath:indexPath];

    NSString *string = [NSString stringWithFormat:@"----%@----", @(indexPath.row)];
    NSDictionary *dict = self.listArray[indexPath.row];
    for (NSString *key in dict.allKeys) {
        NSObject *value = dict[key];
        if ([value isKindOfClass:[NSString class]]) {
            string = value;
            break;
        }
    }

    cell.textLabel.text = string;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    NSString *iconName = [NSString stringWithFormat:@"icon_heart_%zd", indexPath.row % 27];
    cell.imageView.image = [UIImage imageNamed:iconName];
    return cell;
}

/**  **/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //
    NSString *string = @"表格数据: \r\n";
    NSDictionary *dict = self.listArray[indexPath.row];
    for (NSString *key in dict.allKeys) {
        string = [string stringByAppendingString:key];
        string = [string stringByAppendingString:@":"];
        NSObject *value = dict[key];
        if ([value isKindOfClass:[NSString class]]) {
            string = [string stringByAppendingString:(NSString *)value];
        }
        else if ([value isKindOfClass:[NSNumber  class]]) {
            string = [string stringByAppendingString:[(NSNumber *)value stringValue]];
        }
        else {
            string = [string stringByAppendingString:@"------不可展示数据-----"];
        }
        string = [string stringByAppendingString:@"\r\n"];
    }
    WMPrintLogController *pCtrl = [[WMPrintLogController alloc] init];
    pCtrl.text = string;
    [self.navigationController pushViewController:pCtrl animated:YES];
}

@end
