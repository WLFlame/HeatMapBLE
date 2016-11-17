//
//  ErrorDataTableViewController.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/8/31.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "ErrorDataTableViewController.h"

@interface ErrorDataTableViewController ()

@end

@implementation ErrorDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"错误列表";
}

#pragma mark --- TableView DataSource Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.errorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"reuseId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = self.errorArray[indexPath.row];
    return cell;
}





@end
