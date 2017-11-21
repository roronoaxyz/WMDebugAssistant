//
//  WMSandBoxViewController.m
//  MDebugFramework
//
//  Created by micker on 15/9/29.
//  Copyright © 2015年 micker.cn All rights reserved.
//

#import "WMSandBoxViewController.h"
#import "WMDatabaseListController.h"            //数据库


@interface WMSandBoxViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSFileManager  *fileManager;
@end

@implementation WMSandBoxViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editSandbox:) ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SANDBOX_CELL"];
    if (!self.filePath) {
        self.filePath = NSHomeDirectory();
    }
    [self configData];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}

- (void)editSandbox:(id)sender {
    self.tableView.editing = !self.tableView.editing;
}

- (void) configData {
    self.fileManager = [NSFileManager defaultManager];
    self.data = [NSMutableArray arrayWithArray: [self.fileManager contentsOfDirectoryAtPath:self.filePath error:nil]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SANDBOX_CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.data[indexPath.row];
    NSString *subPath = [self.filePath stringByAppendingPathComponent:self.data[indexPath.row]];
    BOOL directiory = NO;
    [_fileManager fileExistsAtPath:subPath isDirectory:&directiory];
    cell.accessoryType = directiory ? UITableViewCellAccessoryDisclosureIndicator :UITableViewCellAccessoryNone;

    NSString *iconName = [NSString stringWithFormat:@"icon_heart_%zd", indexPath.row % 27];
    cell.imageView.image = [UIImage imageNamed:iconName];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle ) {
        NSString *subPath = [self.filePath stringByAppendingPathComponent:self.data[indexPath.row]];
        NSError *error = nil;
        [_fileManager removeItemAtPath:subPath error:&error];
        if (!error) {
            [self.data removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            NSLog(@"delete failed at path:%@", subPath);
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *current = self.data[indexPath.row];
    NSString *subPath = [self.filePath stringByAppendingPathComponent:current];
    BOOL directiory = NO;
    [_fileManager fileExistsAtPath:subPath isDirectory:&directiory];
    
    if (directiory) {
        WMSandBoxViewController *controller = [[WMSandBoxViewController alloc] init];
        controller.title = current;
        controller.filePath = subPath;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if ([subPath hasSuffix:@".db"] || [subPath hasSuffix:@".sqlite"]) {
            WMDatabaseListController *dCtrl = [[WMDatabaseListController alloc] init];
            dCtrl.dbname = subPath;
            [self.navigationController pushViewController:dCtrl animated:YES];
        }
        else {
            [self shareDocumentPath:subPath];
        }

    }
}

    //分享沙盒地址
- (void)shareDocumentPath:(NSString *_Nonnull)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSArray *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;

    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height, 10, 10);
    }
    [self presentViewController:controller animated:YES completion:nil];
}
@end
