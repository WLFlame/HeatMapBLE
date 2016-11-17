//
//  WriteValueTableView.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/9.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "WriteValueTableView.h"

@interface WriteValueTableView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<NSDictionary *> *array;
@end

@implementation WriteValueTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate = self;
        self.array = @[
                       @{
                           @"授权协议" : @"0000"
                           }
                     ,
                       @{
                           @"写入授权" : @""
                           }
                     ,
                       @{
                           @"测试键盘和LED" : @"ff01"
                           },
                     
                       @{
                           @"测试马达" : @"ff02"
                           }
                     ,
                       @{
                            @"测试gps" : @"ff03"
                           }
                    ,
                       @{
                           @"测试电池功能" : @"ff04"
                           }
                     ,
                       @{
                           @"读取系统信息" : @"ffff"
                           }
                     
                       ];
    }
    return self;
}

- (void)setAuthorizationID:(NSString *)authorizationID
{
    _authorizationID = [NSString stringWithFormat:@"7f%@ff", authorizationID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"reuseId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.array[indexPath.row].allKeys.firstObject, self.array[indexPath.row].allValues.firstObject];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDidSeletedRow) {
        self.tableViewDidSeletedRow(indexPath.row, self.array[indexPath.row].allValues.firstObject);
    }
}




@end
