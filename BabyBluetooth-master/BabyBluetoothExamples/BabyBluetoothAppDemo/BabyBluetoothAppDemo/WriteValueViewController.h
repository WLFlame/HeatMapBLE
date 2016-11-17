//
//  WriteValueViewController.h
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/8/29.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "PeripheralInfo.h"
@interface WriteValueViewController : UIViewController
@property (nonatomic, strong)  BabyBluetooth *baby;
@property (nonatomic,strong)CBCharacteristic *characteristic;
@property (nonatomic,strong)CBPeripheral *currPeripheral;
@end
