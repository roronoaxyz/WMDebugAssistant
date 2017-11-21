//
//  WMDatabaseListController.m
//  ELDebug
//
//  Created by roronoa on 2017/9/30.
//  Copyright © 2017年 roronoa. All rights reserved.
//

#import "WMDatabaseListController.h"            //数据库
#import "WMDataBaseTableController.h"
#import "FMDB.h"

@interface WMDatabaseListController ()
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray *tableArray;

@end

@implementation WMDatabaseListController

- (void)dealloc {

    [self.db close];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DATABASE_CELL"];
    self.tableView.tableFooterView = [UIView new];

    self.tableArray = [NSMutableArray new];
    self.db = [FMDatabase databaseWithPath:self.dbname];

    if ([self.db open]) {
        // 
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM sqlite_master where type='table';"];
        FMResultSet *resultSet = [self.db executeQuery:sql];
        // 遍历查询结果
        while (resultSet.next) {
            NSString *str = [resultSet stringForColumnIndex:1];
            [self.tableArray addObject:str];
        }
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DATABASE_CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.tableArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    NSString *iconName = [NSString stringWithFormat:@"icon_heart_%zd", indexPath.row % 27];
    cell.imageView.image = [UIImage imageNamed:iconName];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *tableName = self.tableArray[indexPath.row];
    
    WMDataBaseTableController *lCtrl = [[WMDataBaseTableController alloc] init];
    lCtrl.db = self.db;
    lCtrl.tableName = tableName;
    [self.navigationController pushViewController:lCtrl animated:YES];
}


@end
