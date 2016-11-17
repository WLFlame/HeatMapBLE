//
//  NSString+HEX.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/8/29.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "NSString+HEX.h"

@implementation NSString (HEX)
- (NSString *)hexStringToString
{
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([self UTF8String],0,16)];
//    NSLog(@"心跳数字 10进制 %@",temp10);
    return temp10;
}

- (NSInteger)hexStringToInteger
{
    //转成数字
    int cycleNumber = [[self hexStringToString] intValue];
//    NSLog(@"心跳数字 ：%d",cycleNumber);
    return cycleNumber;
}

- (NSData *) stringToHexData
{
    int len = [self length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

//- (NSString *) dataToHexString
//{
//    NSUInteger          len = [self length];
//    
//    char *              chars = (char *)[self bytes];
//    NSMutableString *   hexString = [[NSMutableString alloc] init];
//    
//    for(NSUInteger i = 0; i < len; i++ )
//        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
//    
//    return hexString;
//}

@end
