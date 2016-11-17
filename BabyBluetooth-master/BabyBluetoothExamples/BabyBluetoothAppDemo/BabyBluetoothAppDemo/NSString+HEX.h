//
//  NSString+HEX.h
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/8/29.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HEX)
- (NSString *)hexStringToString;
- (NSInteger)hexStringToInteger;
- (NSData *) stringToHexData;
- (NSString *) dataToHexString;
@end
