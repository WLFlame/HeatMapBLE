//
//  MapViewModelController.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/21.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "MapViewModelController.h"
#import "TableViewCell.h"
#import "CoordinateDataModel.h"
@interface MapViewModelController ()

@end

@implementation MapViewModelController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    CoordinateDataModel *model = self.models[indexPath.row];
    cell.label.text = [NSString stringWithFormat:@"时间 %@ \r\n 纬度 %f 经度 %f 原始纬度 %@ 经度 %@", model.createDate, model.latitude, model.longitude, model.orignalLatitude, model.orignalLongitude];
    return cell;
}



@end
