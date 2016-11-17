//
//  WriteValueTableView.h
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/9.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteValueTableView : UITableView
@property (nonatomic, copy) NSString *authorizationID;
@property (nonatomic, copy) void(^tableViewDidSeletedRow)(NSInteger index, NSString *code);
@end
