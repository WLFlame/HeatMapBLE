//
//  WriteValueViewController.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/8/29.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "WriteValueViewController.h"
#import "NSString+HEX.h"
#import "SVProgressHUD.h"
#import "NSDate+Formatter.h"
#import "TableViewCell.h"
#import "ErrorDataTableViewController.h"
#import "WriteValueTableView.h"
#import "HeatMapViewController.h"
#import "CoordinateDataModel.h"


#define writeOnCharacteristicView @"peripheralView"
@interface WriteValueViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton *btn5;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 二进制选择数组
@property (nonatomic, strong) NSMutableArray *checkBoxs;
// 发送的数组
@property (nonatomic, strong) NSMutableArray *sendArray;
// 接收到的原始数据
@property (nonatomic, strong) NSMutableArray *dataSource;
// 接收到的模型数组
@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *btnStartRead;
@property (weak, nonatomic) IBOutlet UIButton *btnGenerateMap;

@property (nonatomic, assign) NSInteger seletedIndex;



@property (nonatomic, assign) BOOL isContinous;
@property (nonatomic, assign) BOOL isChained;
@property (nonatomic, strong) NSTimer *sendTimer;

// 发送位置
@property (nonatomic, assign) NSInteger sendIndex;
@property (nonatomic, strong) UIBarButtonItem *chainItem;
@property (nonatomic, strong) UIBarButtonItem *sendItem;
@property (nonatomic, strong) UIBarButtonItem *continousItem;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (nonatomic, strong) WriteValueTableView *functionTestTable;

@property (nonatomic, copy) NSString *readIndexPoint;
@property (nonatomic, assign) BOOL isReadingPoint;


// 位置模型
@property (nonatomic, strong) NSArray<CoordinateDataModel *> *models;

@end

@implementation WriteValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.checkBoxs = [NSMutableArray array];
    self.modelArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 256; index++) {
        [self.checkBoxs addObject:[NSString stringWithFormat:@"%02x", index]];
    }
    
    self.inputField.delegate = self;
    [self.baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
    [self configureUI];
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGes:)];
    edgePan.edges = UIRectEdgeRight;
//    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGes:)];
//    swipeGes.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:edgePan];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
}

- (void)swipeGes:(UISwipeGestureRecognizer *)gesture
{
    NSLog(@"swipe");
    if (self.functionTestTable.frame.origin.x > self.view.bounds.size.width * 0.5) {
        __weak typeof(self) weak_self = self;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect temp = weak_self.functionTestTable.frame;
            temp.origin.x = weak_self.view.bounds.size.width * 0.5;
            weak_self.functionTestTable.frame = temp;
        }];
    }
//    else if (gesture.direction == UISwipeGestureRecognizerDirectionRight && self.functionTestTable.frame.origin.x < self.view.bounds.size.width ) {
//        __weak typeof(self) weak_self = self;
//        [UIView animateWithDuration:0.25 animations:^{
//            CGRect temp = weak_self.functionTestTable.frame;
//            temp.origin.x = weak_self.view.bounds.size.width;
//            weak_self.functionTestTable.frame = temp;
//        }];
//    }
}

- (WriteValueTableView *)functionTestTable
{
    if (!_functionTestTable) {
        _functionTestTable = [[WriteValueTableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 64, self.view.bounds.size.width * 0.5, self.view.bounds.size.height) style:UITableViewStylePlain];
        [self.view addSubview:_functionTestTable];
    
        __weak typeof(self) weak_self = self;
        [_functionTestTable setTableViewDidSeletedRow:^(NSInteger row, NSString *code) {
            if (code != nil && ![code isEqualToString:@""]) {
                NSMutableString *mustring = [NSMutableString string];
                [mustring appendString:@"3f"];
                [mustring appendString:[code substringWithRange:NSMakeRange(0, 2)]];
                [mustring appendString:[code substringWithRange:NSMakeRange(2, 2)]];
                NSInteger sum = [[code substringWithRange:NSMakeRange(0, 2)] hexStringToInteger] + [[code substringWithRange:NSMakeRange(2, 2)] hexStringToInteger];
                NSInteger resualt = sum&0xff;
                [mustring appendString:[@(resualt) stringValue]];
                [mustring appendString:@"ff"];
                [weak_self sendValueCustom:[mustring copy]];
            }
            
            
            switch (row) {
                case 0:
                {
                    // 授权协议
                    
                    
                }
                    break;
                case 1:
                {
                    // 写入授权
                }
                    break;
                case 2:
                {
                    // 测试键盘和LED
                }
                    break;
                case 3:
                {
                    // 测试马达
                }
                    break;
                case 4:
                {
                    // 测试gps
                }
                    break;
                case 5:
                {
                    // 测试电池功能
                }
                    break;
                case 6:
                {
                    // 读取系统信息
                }
                    break;
                default:
                    break;
            }
        }];
    }
    return _functionTestTable;
}

- (void)configureUI
{
    self.sendIndex = 0;
    
    self.dataSource = [NSMutableArray array];
    self.sendArray = [NSMutableArray array];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    self.btn1.enabled = NO;
    self.btn4.enabled = NO;
    self.btn5.enabled = NO;
    
    UIBarButtonItem *chainItem = [[UIBarButtonItem alloc] initWithTitle:@"链式" style:UIBarButtonItemStylePlain target:self action:@selector(chainedSend)];
    self.chainItem = chainItem;
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.sendItem = sendItem;
    
   
    
//    UIBarButtonItem *continousItem = [[UIBarButtonItem alloc] initWithTitle:@"连续" style:UIBarButtonItemStylePlain target:self action:@selector(continousSend)];
//    self.continousItem = continousItem;
    
    self.navigationItem.rightBarButtonItems = @[sendItem, chainItem];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 200, self.view.bounds.size.width, 200)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.hidden = YES;
    [self.view addSubview:self.pickerView];
    [self notifyValue];
}

-(void)writeValue{
    //    int i = 1;
    CBCharacteristicProperties p = self.characteristic.properties;
    if (p & CBCharacteristicPropertyWriteWithoutResponse) {
        Byte b = 0X01;
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    } else if (!(p & CBCharacteristicPropertyWrite)) {
        [SVProgressHUD showInfoWithStatus:@"没有写入权限"];
    } else {
        Byte b = 0X01;
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
    
}
#pragma mark --- NotifyValue
- (void)notifyValue
{
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        __weak typeof(self) weak_self = self;
        //        if(self.characteristic.isNotifying) {
        //            [self.baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
        //        }else{
        [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        [self.baby notify:self.currPeripheral
           characteristic:self.characteristic
                    block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                        if (weak_self.isReadingPoint) {
                            NSString *string = [NSString stringWithFormat:@"%@", characteristics.value];
                            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
                            string = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
                            string = [string stringByReplacingOccurrencesOfString:@">" withString:@""];
                            weak_self.readIndexPoint = [NSString stringWithFormat:@"%@%@", [string substringWithRange:NSMakeRange(20, 2)], [string substringWithRange:NSMakeRange(18, 2)]];
                            [self btnClickStartReadData:nil];
                        }
                        NSLog(@"new value %@",characteristics.value);
                        //                            NSString *string = [[NSString alloc] initWithData:characteristics.value encoding:NSASCIIStringEncoding];
                        [weak_self insertValueToTextView:[NSString stringWithFormat:@"%@", characteristics.value]];
                    }];
        //        }
    }

}


- (void)sendValueCustom:(NSString *)code
{

    [self.currPeripheral writeValue:[code stringToHexData] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)send
{
    
   // 如果没有通知权限 则主动去读取值
    
//    Byte b = 0X01;
//    Byte byte1 = [[self.btn1 titleForState:UIControlStateNormal] hexStringToInteger];
    NSMutableString *muString = [NSMutableString string];
    if (self.inputField.text == nil || ![self.inputField.text isEqualToString:@""]) {
        [muString appendString:self.inputField.text];
    } else {
        [muString appendString:[self.btn1 titleForState:UIControlStateNormal]];
        [muString appendString:[self.btn3 titleForState:UIControlStateNormal]];
        [muString appendString:[self.btn2 titleForState:UIControlStateNormal]];
        
        [muString appendString:[self.btn4 titleForState:UIControlStateNormal]];
        [muString appendString:[self.btn5 titleForState:UIControlStateNormal]];
        
    }
//    NSLog(@"%@", [[self.btn1 titleForState:UIControlStateNormal] stringToHexData]);
//    Byte[] bytes =
    
//    Byte b = 0X01;
//    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
//    Byte b = 0X01;
//    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
//    NSLog(@"%@", [[@"123" copy] dataUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"%@", [muString stringToHexData]);
    [self.currPeripheral writeValue:[muString stringToHexData] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    __weak typeof(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!(self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate)) {
        [[weak_self baby] setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
            NSString *string = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
            [weak_self insertValueToTextView:string];
        }];
//            [[weak_self baby] setBlockOnReadValueForCharacteristicAtChannel:writeOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//                NSString *string = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
//                [weak_self insertValueToTextView:string];
//            }];
//        }
    });
    
}

- (void)checkResults
{
    NSInteger receiveIndex = 0;
    // 丢包的数据
    NSMutableArray *errorArray = [NSMutableArray array];
    for (NSString *sendData in self.sendArray) {
        NSString *receiveData =  self.dataSource[receiveIndex];
        if (![receiveData containsString:sendData]) {
            [errorArray addObject:receiveData];
        } else {
            receiveIndex++;
        }
    }
    
    if (errorArray.count) {
        ErrorDataTableViewController *vc = [[ErrorDataTableViewController alloc] init];
        vc.errorArray = errorArray;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [SVProgressHUD showInfoWithStatus:@"全部传输完成，无丢包"];
    }
   
}


- (void)timeSend
{
   
    if (self.sendIndex == 2048) {
        NSLog(@"asdfas");
        return;
    }
    
    NSMutableString *muString = [NSMutableString string];
    [muString appendString:[self.btn1 titleForState:UIControlStateNormal]];
    
//    [muString appendString:[self.btn2 titleForState:UIControlStateNormal]];
//    [muString appendString:[self.btn3 titleForState:UIControlStateNormal]];
    
    [muString appendString:[NSString stringWithFormat:@"%04x", self.sendIndex]];
    
//    [muString appendString:[self.btn4 titleForState:UIControlStateNormal]];
    [muString appendString:[NSString stringWithFormat:@"%02x", self.sendIndex&0xff]];
    [muString appendString:[self.btn5 titleForState:UIControlStateNormal]];
    
//    NSMutableString *temp = [NSMutableString string];
    
//    for (NSInteger j = 0; j < 16; j++) {
//        [temp appendString:[NSString stringWithFormat:@"%02x", arc4random_uniform(256)]];
//        
//    }
    [self.sendArray insertObject:muString atIndex:0];
    [self.currPeripheral writeValue:[muString stringToHexData] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    self.sendIndex++;
}

- (void)continousSend
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.isContinous = YES;
    [self.dataSource removeAllObjects];
    [self.sendArray removeAllObjects];
    [self.tableView reloadData];
    if (!self.sendTimer) {
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timeSend) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.sendTimer forMode:NSRunLoopCommonModes];
    }
   
    
//    for (NSInteger index = 0; index < 2048; index++) {
//        
//        sleep(1);
//       
//    }
    
    
}

- (void)analysisDataSource
{
    NSLog(@"%zd", self.dataSource.count);
    NSArray *models = [CoordinateDataModel modelWithStringArray:self.dataSource];
    self.models = models;
}

- (void)chainedSend
{
    
    

    
    self.isContinous = YES;
    self.isChained = YES;
//    if (self.sendIndex == 2048) {
//        self.isContinous = NO;
//        self.isChained = NO;
//        self.sendIndex = 0;
////        [self analysisDataSource];
//        self.btnGenerateMap.enabled = YES;
//        return;
//    }
    
    
    NSMutableString *muString = [NSMutableString string];
    [muString appendString:[self.btn1 titleForState:UIControlStateNormal]];
    
//    [muString appendString:[NSString stringWithFormat:@"%04x", self.sendIndex]];
    // 大端模式
    NSString *hexIndex = [NSString stringWithFormat:@"%04lx", (long)self.sendIndex];
    NSString *twoHex = [hexIndex substringWithRange:NSMakeRange(2, 2)];
    [muString appendString:twoHex];
    NSString *threeHex = [hexIndex substringWithRange:NSMakeRange(0, 2)];
    [muString appendString:threeHex];
//
    
    NSInteger resualt = [twoHex hexStringToInteger] + [threeHex hexStringToInteger];
//    [muString appendString:[self.btn4 titleForState:UIControlStateNormal]];
    
    [muString appendString:[NSString stringWithFormat:@"%02x", resualt&0xff]];
    [muString appendString:[self.btn5 titleForState:UIControlStateNormal]];
    
    NSLog(@"chain send %@", muString);
    
    [self.sendArray insertObject:muString atIndex:0];
    [self.currPeripheral writeValue:[muString stringToHexData] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    if (self.sendIndex == 1) {
        self.sendIndex = 2047;
    }
    self.sendIndex--;
   
    NSLog(@"sendIndex %zd", self.sendIndex);
}

- (void)insertValueToTextView:(NSString *)value
{
    value = [[[value stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
   
    if (self.isContinous) {
//        NSLog(@"%@" ,[NSString stringWithFormat:@"%zd %@",self.dataSource.count, value]);
        [self.dataSource insertObject:[NSString stringWithFormat:@"%zd %@",self.dataSource.count, value] atIndex:0];
//        CoordinateDataModel *model = [[CoordinateDataModel alloc] initWithString:value];
//        [self.dataSource insertObject:model atIndex:0];
//        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        
        if (self.dataSource.count == 2047) {
            self.isContinous = NO;
            self.isChained = NO;
            NSString *documentPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//            NSData *resualt = [NSKeyedArchiver archivedDataWithRootObject:self.dataSource];
//            BOOL resualt = [self.dataSource writeToURL:[NSURL URLWithString:[documentPath stringByAppendingPathComponent:@"temp.plist"] ] atomically:YES];
            BOOL isSuceess = [self.dataSource writeToFile:[documentPath stringByAppendingPathComponent:@"temp2.plist"] atomically:YES];
            if (isSuceess) {
                NSLog(@"success");
            } else {
                NSLog(@"failed");
            }
            self.sendIndex = 0;
            [self.sendTimer invalidate];
            self.sendTimer = nil;
            self.btnGenerateMap.enabled = YES;
            [self analysisDataSource];
            self.navigationItem.rightBarButtonItem.enabled = YES;
             [SVProgressHUD showInfoWithStatus:@"2048个包已传输完成，开始校对"];
            __weak typeof(self) weak_self = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                         weak_self.isContinous = NO;
                        
                        // 校对
                        [weak_self checkResults];
                    });
                });
                
            });
         
            return;
        }
        
        if (self.isChained) {
            [self chainedSend];
        }
        
    } else {
        value = [NSString stringWithFormat:@"%@ %@", [NSDate currentDateStringWithFormat:@"HH:mm:ss"], value];
        [self.dataSource insertObject:value atIndex:0];
//        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
  
}

- (IBAction)btnClick1:(id)sender {
    self.seletedIndex = 1;
    self.pickerView.hidden = NO;
    NSLog(@"%@", [self.btn1 titleForState:UIControlStateNormal]);
    NSLog(@"%zd", [[self.btn1 titleForState:UIControlStateNormal] hexStringToInteger]);
    [self.pickerView selectRow:[[self.btn1 titleForState:UIControlStateNormal] hexStringToInteger] inComponent:0 animated:YES];
}

- (IBAction)btnClick2:(id)sender {
    self.seletedIndex = 2;
    self.pickerView.hidden = NO;
   
    
}


- (IBAction)btnClick3:(id)sender {
    self.seletedIndex = 3;
    self.pickerView.hidden = NO;
    }

- (IBAction)btnClick4:(id)sender {
    self.seletedIndex = 4;
    self.pickerView.hidden = NO;
}

- (IBAction)btnClick5:(id)sender {
    self.seletedIndex = 5;
    self.pickerView.hidden = NO;
}


- (UIButton *)getBtnWithIndex:(NSInteger)index
{
    if (index == 1) {
        return self.btn1;
    } else if (index == 2) {
        return self.btn2;
    } else if (index == 3) {
        return  self.btn3;
    } else if (index == 4) {
        return self.btn4;
    }
    return self.btn5;
}

// 根据数据生成热图
- (IBAction)btnClickGenerateHotMap:(id)sender {
    HeatMapViewController *heatMapVc = [[HeatMapViewController alloc] init];
    heatMapVc.models = self.models;
    [self.navigationController pushViewController:heatMapVc animated:YES];
}

// 读入数据
- (IBAction)btnClickStartReadData:(id)sender {
    NSString *documentPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[documentPath stringByAppendingPathComponent:@"temp2.plist"]];
    
    __weak typeof(self) weak_self = self;
    if (array.count > 0 && self.readIndexPoint == nil) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否使用上次的数据" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"使用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weak_self.dataSource addObjectsFromArray:array];
             [weak_self analysisDataSource];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           
            weak_self.btnGenerateMap.enabled = NO;
            // 获取位置指针
            if (weak_self.readIndexPoint == nil) {
                weak_self.isReadingPoint = YES;
                [weak_self sendValueCustom:@"3f000000ff"];
                
            } else {
                weak_self.isReadingPoint = NO;
                NSLog(@"%@", weak_self.readIndexPoint);
                weak_self.sendIndex = [weak_self.readIndexPoint hexStringToInteger];
                
                //        self.sendIndex = 1;
                [weak_self chainedSend];
            }
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    } else {
        self.isReadingPoint = NO;
        NSLog(@"%@", self.readIndexPoint);
        self.sendIndex = [weak_self.readIndexPoint hexStringToInteger];
        
        //        self.sendIndex = 1;
        [self chainedSend];
    }
   
    
}


#pragma mark --- UIPickerViewDataSource Method
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.checkBoxs.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.checkBoxs[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerView.hidden = YES;
    NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
    [[self getBtnWithIndex:self.seletedIndex] setTitle:title forState:UIControlStateNormal];
    NSString *title1 = [self.btn2 titleForState:UIControlStateNormal];
    NSString *title2 = [self.btn3 titleForState:UIControlStateNormal];
    NSInteger sum = [title1 hexStringToInteger] + [title2 hexStringToInteger];
    NSInteger resualt = sum&0xff;
    NSLog(@"%@", [NSString stringWithFormat:@"%02x", sum]);
    NSLog(@"%zd", resualt);
//    if (sum < 256) {
        NSString *hexString = [NSString stringWithFormat:@"%02x", resualt];
        
        [self.btn4 setTitle:hexString  forState:UIControlStateNormal];
//    } else {
//        [SVProgressHUD showInfoWithStatus:@"出现错误"];
//    }
}


#pragma mark --- TableView DataSource Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
//    CoordinateDataModel *model = [[CoordinateDataModel alloc] initWithString:[self.dataSource[indexPath.row] componentsSeparatedByString:@" "].lastObject];
//    [self.modelArray addObject:model];
//    cell.label.text = [NSString stringWithFormat:@"时间 %@ \r\n 纬度 %f 经度 %f \r\n 原始纬度 %@ 经度 %@ \r\n 速度 %f", model.createDate, model.latitude, model.longitude, model.orignalLatitude, model.orignalLongitude, model.speed];
//    cell.label.text = [NSString stringWithFormat:@"%d", indexPath.row];
    cell.label.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( self.functionTestTable.frame.origin.x < self.view.bounds.size.width ) {
        __weak typeof(self) weak_self = self;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect temp = weak_self.functionTestTable.frame;
            temp.origin.x = weak_self.view.bounds.size.width;
            weak_self.functionTestTable.frame = temp;
        }];
    }

}

#pragma mark ---- UITextField Delegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
