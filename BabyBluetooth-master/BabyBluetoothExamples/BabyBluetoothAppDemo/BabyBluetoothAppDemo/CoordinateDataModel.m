//
//  CoordinateDataModel.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/12.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "CoordinateDataModel.h"
#import "NSString+HEX.h"
#import "QZDateUtil.h"
#import "NSDecimalNumber+Extensions.h"
#include "gps_convert.h"


@implementation CoordinateDataModel

- (instancetype)initWithString:(NSString *)string
{
    if (self = [super init]) {
//        
//        [self convertNMEA:@"3042.6962"];
//        [self convertNMEA:@"10402.1972"];
//        
        NSMutableString *appendString = [NSMutableString string];
        
        NSString *dateString = [NSString stringWithFormat:@"20%ld-%ld-%ld", (long)[[string substringWithRange:NSMakeRange(2, 2)] hexStringToInteger], (long)[[string substringWithRange:NSMakeRange(4, 2)] hexStringToInteger], (long)[[string substringWithRange:NSMakeRange(6, 2)] hexStringToInteger]];
//        self.date = [string substringWithRange:NSMakeRange(2, 6)];
        NSString *timeString = [NSString stringWithFormat:@"%d-%ld-%ld", [[string substringWithRange:NSMakeRange(8, 2)] hexStringToInteger] + 8, (long)[[string substringWithRange:NSMakeRange(10, 2)] hexStringToInteger], (long)[[string substringWithRange:NSMakeRange(12, 2)] hexStringToInteger]];
//        self.time = [string substringWithRange:NSMakeRange(8, 6)];
        
        [appendString appendString:dateString];
        [appendString appendString:@" "];
        [appendString appendString:timeString];
        
        self.createDate = [CoordinateDataModel getNowDateFromatAnDate:[[QZDateUtil sharedUtil] formateDateString:[appendString copy] andFormate:@"yyyy-MM-dd HH-mm-ss"]];
        
        NSString *reverseLatitudeinteger = [NSString stringWithFormat:@"%@%@", [string substringWithRange:NSMakeRange(16, 2)], [string substringWithRange:NSMakeRange(14, 2)]];
        NSString *reverseLatitudefloat = [NSString stringWithFormat:@"%@%@", [string substringWithRange:NSMakeRange(20, 2)], [string substringWithRange:NSMakeRange(18, 2)]];
        self.orignalLatitude = [NSString stringWithFormat:@"%ld.%ld",(long)[reverseLatitudeinteger hexStringToInteger], (long)[reverseLatitudefloat hexStringToInteger] ];
        
//        self.latitude = [self convertNMEA:[NSString stringWithFormat:@"%ld.%ld",(long)[reverseLatitudeinteger hexStringToInteger], (long)[reverseLatitudefloat hexStringToInteger] ]];
        char *dd[32];
        char *temp[32];
        ddmm2dd([self.orignalLatitude UTF8String], dd, temp);
        self.latitude = [[NSString stringWithCString:dd encoding:NSUTF8StringEncoding] floatValue];
        
        NSString *reverseLongitudeinteger = [NSString stringWithFormat:@"%@%@", [string substringWithRange:NSMakeRange(24, 2)], [string substringWithRange:NSMakeRange(22, 2)]];
        NSString *reverseLongitudefloat = [NSString stringWithFormat:@"%@%@", [string substringWithRange:NSMakeRange(28, 2)], [string substringWithRange:NSMakeRange(26, 2)]];
        self.orignalLongitude = [NSString stringWithFormat:@"%ld.%ld",(long)[reverseLongitudeinteger hexStringToInteger], (long)[reverseLongitudefloat hexStringToInteger] ];
       
//        self.longitude = [self convertNMEA:[NSString stringWithFormat:@"%ld.%ld",(long)[reverseLongitudeinteger hexStringToInteger], (long)[reverseLongitudefloat hexStringToInteger] ]];
        
        ddmm2dd([self.orignalLongitude UTF8String], dd, temp);
        self.longitude = [[NSString stringWithCString:dd encoding:NSUTF8StringEncoding] floatValue];
        
        
        self.speed = (float)[[string substringWithRange:NSMakeRange(32, 2)] hexStringToInteger] / 10;
        self.goal = [[string substringWithRange:NSMakeRange(34, 2)] hexStringToInteger];
        self.originalValue = string;
    }
    return self;
}

+ (NSArray *)modelWithStringArray:(NSArray *)array
{
    NSMutableArray *models = [NSMutableArray array];
//    NSDate *previousDate = [self getNowDateFromatAnDate:[NSDate date]];
//    previousDate = [previousDate dateByAddingTimeInterval:- (3600 * 3) ];
    for (NSString *component in array) {
        CoordinateDataModel *model = [[CoordinateDataModel alloc] initWithString:[component componentsSeparatedByString:@" "].lastObject];
            [models addObject:model];
        
    }
    return models;
}


+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

- (CGFloat)convertNMEA:(NSString *)value
{
    // abc+(de/60)+(fghi/600000)
    NSString *abc = @"0";
    NSString *de = @"0";
    NSString *fghi = @"0";
    
    NSString *decimal = [value componentsSeparatedByString:@"."].lastObject;
    NSString *integer = [value componentsSeparatedByString:@"."].firstObject;
    if (integer.length < 5 && integer.length >= 4 ) {
        abc = [integer substringWithRange:NSMakeRange(0, 2)];
        de = [integer substringWithRange:NSMakeRange(2, 2)];
    } else if (integer.length >= 4) {
        abc = [integer substringWithRange:NSMakeRange(0, 3)];
        de = [integer substringWithRange:NSMakeRange(3, 2)];
    }
    
    if (decimal.length >= 4) {
        fghi = [decimal substringWithRange:NSMakeRange(0, 4)];
    }
    
    
    NSDecimalNumber *abcDecimal = [[NSDecimalNumber alloc] initWithString:abc];
    NSDecimalNumber *deDecimal = [[NSDecimalNumber alloc] initWithString:de];
    NSDecimalNumber *fghiDeciaml = [[NSDecimalNumber alloc] initWithString:fghi];
    
    NSDecimalNumber *resualtDecimal = [[abcDecimal decimalNumberByAdding:[deDecimal decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithString:@"60"]]] decimalNumberByAdding:[fghiDeciaml decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithString:@"600000"]]];
    // 保留小数点后6位
   
    return [[resualtDecimal roundToScale:6] doubleValue];
}

@end
