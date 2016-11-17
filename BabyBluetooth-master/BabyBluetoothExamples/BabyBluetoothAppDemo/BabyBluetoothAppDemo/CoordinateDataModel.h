//
//  CoordinateDataModel.h
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/12.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CoordinateDataModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) NSInteger goal;
@property (nonatomic, copy) NSString *orignalLatitude;
@property (nonatomic, copy) NSString *orignalLongitude;

@property (nonatomic, copy) NSString *orginalHexLatitude;
@property (nonatomic, copy) NSString *originalHexLongtitude;

@property (nonatomic, copy) NSString *originalValue;

- (instancetype)initWithString:(NSString *)string;

+ (NSArray *)modelWithStringArray:(NSArray *)array;

@end
