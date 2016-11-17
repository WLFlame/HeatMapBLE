    //
//  ViewController.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/1.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"


//screen width and height
#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height

@interface ViewController (){
//    UITableView *tableView;
    NSMutableArray *peripherals;
    NSMutableArray *peripheralsAD;
    BabyBluetooth *baby;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc]init];
    peripheralsAD = [[NSMutableArray alloc]init];
   
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
    //启动一个定时任务
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    
    
    const int SecretCode[]=
    {0xB4,0x88,0x94,0x4A,0x4D,0xC6,0x04,0xC2,
        
        0xD0,0xB5,0x0C,0x6A,0xDC,0xCA,0x5F,0xF5,
        
        0xDE,0x0E,0xF2,0x5D,0x86,0xC4,0x0E,0x97,
        
        0x78,0x4C,0x9F,0xA5,0x43,0x47,0xD4,0xD2,
        
        0x96,0xFB,0xE8,0x3A,0xB1,0xFA,0x3E,0x88,
        
        0x1B,0xFF,0xAC,0x04,0x93,0x1A,0x1A,0xCC,
        
        0x49,0x0C,0x4B,0x61,0x4D,0xF2,0xFA,0x66,
        
        0x47,0x29,0x2A,0xA5,0x69,0x69,0xB6,0x53,
        
        0xA1,0x35,0x2F,0x95,0x15,0x75,0xE7,0x43,
        
        0xC8,0x61,0x4A,0xEA,0xA1,0xA0,0x6D,0x19,
        
        0x8F,0xB1,0xE9,0xD5,0x06,0x8B,0xEA,0x6E,
        
        0xAD,0x80,0x83,0x76,0x5A,0x67,0x45,0x0E,
        
        0x3E,0xFA,0x10,0x64,0x5D,0x7D,0x28,0x79,
        
        0x42,0xA0,0x8A,0x28,0xEF,0xA7,0x81,0x64,
        
        0x1B,0xC8,0x75,0xC0,0x98,0xD4,0x05,0x36,
        
        0x13,0x1B,0x55,0x21,0x00,0x89,0xA8,0x8B,
        
        0xD3,0x15,0x31,0xAD,0x74,0x5B,0x26,0xB4,
        
        0xED,0x87,0x17,0xC1,0x66,0x76,0x7E,0x35,
        
        0x54,0x18,0x96,0x2B,0xED,0x19,0x71,0x46,
        
        0xDE,0xBF,0x46,0xAC,0x41,0x17,0x08,0x52,
        
        0xC9,0x4C,0x3C,0x7B,0x41,0x57,0x0B,0x7B,
        
        0x35,0xDC,0x96,0xC1,0xED,0x54,0x8A,0x15,
        
        0xA2,0x69,0xF5,0x1D,0xEB,0x9E,0x59,0x26,
        
        0x7A,0x38,0xFD,0x21,0x07,0x58,0x8C,0xEB};
    
    NSInteger result = 0xE9 & 0x94;
    NSLog(@"%02x", result);
    NSLog(@"%zd", sizeof(SecretCode) / sizeof(SecretCode[0]));
    NSInteger count = sizeof(SecretCode) / sizeof(SecretCode[0]);
    for (NSInteger index = 0; index < count; index++) {
        NSLog(@"%zd", SecretCode[index]);
    }
}

-(void)timerTask{
//    NSLog(@"timerTask");

}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
}

#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
        //找到cell并修改detaisText
        for (int i=0;i<peripherals.count;i++) {
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell.textLabel.text isEqualToString:peripheral.name]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)peripheral.services.count];
            }
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    

    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
//        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
//            return YES;
//        }
//        return NO;
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];

    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
       
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
        
        参数分别使用在下面这几个地方，若不使用参数则传nil
        - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
        - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
        - [peripheral discoverServices:discoverWithServices];
        - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
        
        该方法支持channel版本:
            [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    

}

#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        [peripherals addObject:peripheral];
        [peripheralsAD addObject:advertisementData];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
    NSDictionary *ad = [peripheralsAD objectAtIndex:indexPath.row];

    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *localName;
    if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
        localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
    }else{
        localName = peripheral.name;
    }
    
    cell.textLabel.text = localName;
    //信号和服务
    cell.detailTextLabel.text = @"读取中...";
    //找到cell并修改detaisText
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    if (serviceUUIDs) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)serviceUUIDs.count];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service"];
    }
    
    //次线程读取RSSI和服务数量
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralViewContriller *vc = [[PeripheralViewContriller alloc]init];
    vc.currPeripheral = [peripherals objectAtIndex:indexPath.row];
    vc->baby = self->baby;
    [self.navigationController pushViewController:vc animated:YES];
    
}



@end
