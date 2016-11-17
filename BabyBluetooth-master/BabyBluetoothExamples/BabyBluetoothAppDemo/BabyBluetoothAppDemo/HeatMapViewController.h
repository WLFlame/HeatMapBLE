//
//  HeatMapViewController.h
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/12.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoordinateDataModel;
@interface HeatMapViewController : UIViewController
@property (nonatomic, strong) NSArray<CoordinateDataModel *> *models;
@end
