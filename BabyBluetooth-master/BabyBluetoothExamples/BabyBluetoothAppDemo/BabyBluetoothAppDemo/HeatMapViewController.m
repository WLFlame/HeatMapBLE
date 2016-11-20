//
//  HeatMapViewController.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/12.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "HeatMapViewController.h"
#import "UIImage+CCHeatMap.h"
#import "CoordinateDataModel.h"
#import "NSDate+WLDate.h"
#import "RMDateSelectionViewController.h"
#import "TTGlobalUICommon.h"
#import <MJExtension/MJExtension.h>
#import <AVOSCloud/AVOSCloud.h>
#import "MBProgressHUD+Add.h"
#import "MapViewModelController.h"
#import "MBProgressHUD.h"
#import <AVOSCloud/AVOSCloud.h>
#import "SVProgressHUD.h"
@interface HeatMapViewController () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *heatImageView;
@property (nonatomic, strong) NSMutableArray<CLLocation *> *locations;
@property (nonatomic, strong) NSMutableArray *weights;
@property (nonatomic, assign) CGFloat deltaLa;
@property (nonatomic, assign) CGFloat deltaLo;
@property (nonatomic, strong) NSMutableArray *tempModels;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, assign) CGFloat originalDistance;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
// 缩放系数
@property (nonatomic, assign) CGFloat zoomRadio;

@property (nonatomic, copy) NSString *pointStr1;
@property (nonatomic, copy) NSString *pointStr2;


@end

@implementation HeatMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:_mapView];3f100917051e24d80baf21a428f1060000edff
//    _mapView.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.originalDistance = 0;
    self.heatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 44)];
    self.originalDistance = 0;
    self.zoomRadio = 1;
    [self.view addSubview:_heatImageView];
    
    _locations = [NSMutableArray array];
    _weights = [NSMutableArray array];
    _pointArray = [NSMutableArray array];
    
    self.heatImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
    [self.heatImageView addGestureRecognizer:tapGes];
    [self configureUI];
    
}

- (void)upload
{
    AVFile *file = [AVFile fileWithData:[self.pointStr1 dataUsingEncoding:NSUTF8StringEncoding]];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"上传数据成功"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"上传数据失败"];
            
        }
    }];
    AVFile *file2 = [AVFile fileWithData:[self.pointStr2 dataUsingEncoding:NSUTF8StringEncoding]];
    [file2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        if (succeeded) {
        //            [SVProgressHUD showSuccessWithStatus:@"上传数据成功"];
        //        } else {
        //            [SVProgressHUD showErrorWithStatus:@"上传数据失败"];
        //
        //        }
    }];

}

- (void)configureUI
{
    UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStylePlain target:self action:@selector(choseStart)];
    UIBarButtonItem *end = [[UIBarButtonItem alloc] initWithTitle:@"结束" style:UIBarButtonItemStylePlain target:self action:@selector(choseEnd)];
    UIBarButtonItem *upload = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
    UIBarButtonItem *viewModel = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(viewModel)];
    self.navigationItem.rightBarButtonItems = @[end,start,viewModel,upload ];
    
//    UIStepper *stepper = [[UIStepper alloc] init];
//    self.navigationItem.titleView = stepper;
//    [stepper addTarget:self action:@selector(blowUpOrShrink:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *shrinkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [shrinkBtn addTarget:self action:@selector(blowUpOrShrink:) forControlEvents:UIControlEventTouchUpInside];
    [shrinkBtn setTitle:@"缩小" forState:UIControlStateNormal];
    [shrinkBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [shrinkBtn sizeToFit];
    shrinkBtn.tag = 0;
    UIBarButtonItem *shrinkItem = [[UIBarButtonItem alloc] initWithCustomView:shrinkBtn];
    
    UIButton *plusBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [plusBtn addTarget:self action:@selector(blowUpOrShrink:) forControlEvents:UIControlEventTouchUpInside];
    [plusBtn setTitle:@"放大" forState:UIControlStateNormal];
    [plusBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [plusBtn sizeToFit];
    plusBtn.tag = 1;
    UIBarButtonItem *plusItem = [[UIBarButtonItem alloc] initWithCustomView:plusBtn];
    
    self.navigationItem.leftBarButtonItems = @[plusItem, shrinkItem];
    
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 64, self.view.bounds.size.width, 30);
    label.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:label];
    self.distanceLabel = label;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)choseStart
{
    __weak typeof(self) weak_self = self;
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
//        NSLog(@"Successfully selected date: %@", ((UIDatePicker *)controller.contentView).date);
        NSDate *choseDate = ((UIDatePicker *)controller.contentView).date;
        weak_self.startDate = [choseDate getNowDateFromatAnDate];
        self.tabBarController.tabBar.hidden = NO;
    }];
    
    //Create cancel action
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        self.tabBarController.tabBar.hidden = NO;
//        NSLog(@"Date selection was canceled");
    }];
    
    //Create date selection view controller
    RMDateSelectionViewController *dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:RMActionControllerStyleWhite selectAction:selectAction andCancelAction:cancelAction];
    dateSelectionController.title = @"选择开始时间";
    dateSelectionController.message = @"Please choose a date and press 'Select' or 'Cancel'.";
    
    //Now just present the date selection controller using the standard iOS presentation method
    [self presentViewController:dateSelectionController animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)choseEnd
{
    
    if (self.startDate == nil) {
        TTAlert(@"请选择开始时间");
        return;
    }
    __weak typeof(self) weak_self = self;
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
        self.tabBarController.tabBar.hidden = NO;
//        NSLog(@"Successfully selected date: %@", ((UIDatePicker *)controller.contentView).date);
        weak_self.endDate = [((UIDatePicker *)controller.contentView).date getNowDateFromatAnDate];
        
        [weak_self resetHeatImageView];
        
    }];
    
    //Create cancel action
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        self.tabBarController.tabBar.hidden = NO;
//        NSLog(@"Date selection was canceled");
    }];
    
    //Create date selection view controller
    RMDateSelectionViewController *dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:RMActionControllerStyleWhite selectAction:selectAction andCancelAction:cancelAction];
//    dateSelectionController.datePicker.minimumDate = weak_self.startDate;
    dateSelectionController.title = @"选择结束时间";
    dateSelectionController.message = @"Please choose a date and press 'Select' or 'Cancel'.";
    
    //Now just present the date selection controller using the standard iOS presentation method
    [self presentViewController:dateSelectionController animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewModel
{
    if (self.tempModels.count > 0) {
        MapViewModelController *modelVc = [[MapViewModelController alloc] init];
        modelVc.models = self.tempModels;
        [self.navigationController pushViewController:modelVc animated:YES];
    }
}

- (void)resetHeatImageView
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.heatImageView.image = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self tapImage];
    });
    
    
}

- (void)tapImage
{
    
    [_locations removeAllObjects];
    [_pointArray removeAllObjects];
    [_weights removeAllObjects];
    
    CGFloat maxLa = 0.01;
    CGFloat minLa = 1000;
    CGFloat maxLo = 0.01;
    CGFloat minLo = 1000;
    
    BOOL filterWithDate = self.startDate && self.endDate;
    
    self.tempModels = [NSMutableArray array];
    NSMutableString *pointStr = [NSMutableString string];
    NSMutableString *locStr = [NSMutableString string];
    NSInteger index = 0;
    for (CoordinateDataModel *model in self.models) {
        if (model.latitude < 30 || model.longitude < 100) {
            continue;
        }
        
        if (filterWithDate) {
//            model.createDate = [[NSDate date] dateByAddingTimeInterval:-3600];
            if (!([model.createDate compare:self.startDate] == NSOrderedDescending && [model.createDate compare:self.endDate] == NSOrderedAscending)) {
                continue;
            }
        }
        
        [self.tempModels addObject:model];
        [pointStr appendString:[NSString stringWithFormat:@"point%zd,%f,%f,%@,%@,%@\n",index, model.latitude, model.longitude, model.orignalLatitude,model.orignalLongitude, model.originalValue]];
        [locStr appendString:[NSString stringWithFormat:@"%f,%f\n", model.latitude,model.longitude]];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude];
        NSLog(@"createDate %@ latitude %f longitude %f",model.createDate,  location.coordinate.latitude, location.coordinate.longitude);
        NSLog(@"%@", model.originalValue);
        [_pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(model.longitude, model.latitude)]];
        [_locations addObject:location];
        [_weights addObject:@1];
        
        if (model.latitude > maxLa) {
            maxLa = model.latitude;
        }
        
        if (model.latitude < minLa ) {
            minLa = model.latitude;
        }
        
        if (model.longitude > maxLo) {
            maxLo = model.longitude;
        }
        
        if (model.longitude < minLo) {
            minLo = model.longitude;
        }
        index++;
    }
    
    //    CGPoint topLeftP = CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
    self.pointStr1 = pointStr;
    self.pointStr2 = locStr;
  //    NSLog(@"max %f min %f", maxLa - minLa, maxLo - minLo);
    self.deltaLa = maxLa - minLa;
    self.deltaLo = maxLo - minLo;
    
    CGFloat proportion = 0;
    
    // 计算依照高度还是宽度
    CGFloat margin = 15;
    CGRect screenR = CGRectMake(0, 0, self.heatImageView.frame.size.width - 2 * margin, self.heatImageView.bounds.size.height - 2 * margin);
//    CGRect screenR = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
    CGFloat heightRate = screenR.size.height / self.deltaLa;
    if (heightRate * self.deltaLo > screenR.size.width) {
        proportion = screenR.size.width / self.deltaLo;
    } else {
        proportion = heightRate;
    }
    
    proportion *= self.zoomRadio;
    
    // 计算距离()
//    if (self.originalDistance == 0) {
//        CGFloat maxDistance = 0;
//        CLLocation *iMaxLoc = nil;
//        CLLocation *jMaxLoc = nil;
//        NSInteger iIndex = 0;
//        NSInteger jIndex = 0;
//        for (NSInteger i = 0; i < _locations.count; i++) {
//            CLLocation *iLoc = _locations[i];
//            for (NSInteger j = i + 1; j < _locations.count; j++) {
//                CLLocation *jLoc = _locations[j];
//                CGFloat tempDistance = [iLoc distanceFromLocation:jLoc];
//                NSLog(@"temp distance %f", tempDistance);
//                if (tempDistance > maxDistance) {
//                    maxDistance = tempDistance;
//                    iMaxLoc = iLoc;
//                    jMaxLoc = jLoc;
//                    iIndex = i;
//                    jIndex = j;
//                }
//            }
//        }
//        if (self.tempModels.count != 0) {
//            NSLog(@"%@", ((CoordinateDataModel *)self.tempModels[iIndex]).createDate);
//            NSLog(@"%@", ((CoordinateDataModel *)self.tempModels[jIndex]).createDate);
//            NSLog(@"original %@ %@",((CoordinateDataModel *)self.tempModels[iIndex]).orignalLatitude, ((CoordinateDataModel *)self.tempModels[iIndex]).orignalLongitude);
//            NSLog(@"original %@ %@", ((CoordinateDataModel *)self.tempModels[jIndex]).orignalLatitude, ((CoordinateDataModel *)self.tempModels[jIndex]).orignalLongitude);
//            NSLog(@"%f", maxDistance);
//            self.originalDistance = maxDistance;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                 self.distanceLabel.text = [NSString stringWithFormat:@"%fm", maxDistance];
//            });
//           
//        }
//        
//    } else {
//        self.originalDistance /= self.zoomRadio;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.distanceLabel.text = [NSString stringWithFormat:@"%fm", self.originalDistance];
//        });
//    }
    
    
    
    
//    NSArray *plistArray = [CoordinateDataModel mj_keyValuesArrayWithObjectArray:self.tempModels];
//    NSLog(@"%@",plistArray);
    
//     NSString *writePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"bbq.plist"];
//    // 显示的矩形
//    BOOL success = [plistArray writeToFile:writePath atomically:YES];
//    if (success) {
//        NSLog(@"success");
//        AVFile *file = [AVFile fileWithName:@"bbq.plist" contentsAtPath:writePath];
//        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (success) {
//                NSLog(@"upload success");
//            }
//        }];
//    }
    
    
    //    CGFloat distance = sqrt(showWidth * showWidth + showHeight * showHeight);
    
    //    CGFloat deltaDistance = sqrt(self.deltaLa * self.deltaLa + self.deltaLo * self.deltaLo);
    
    //    CGFloat rate = distance / deltaDistance;
    // 最左上角的点 (minLo, maxLa) 右下角的点 (maxLo, minLa)
    
    
    
    NSMutableArray *converArray = [NSMutableArray array];
    for (NSValue *pValue in _pointArray) {
        CGPoint p = [pValue CGPointValue];
        p.x = (p.x - minLo) >= 0 ? (p.x - minLo) : -(p.x - minLo) ;
        p.y = (p.y - maxLa) >= 0 ? (p.y - maxLa) : -(p.y - maxLa);
        p.x *= proportion;
        p.x += margin;
        p.y *= proportion;
        p.y += margin;
//        NSLog(@"convert x %f y %f", p.x, p.y);
        [converArray addObject:[NSValue valueWithCGPoint:p]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (converArray.count == 0) {
            TTAlert(@"该时间段没有数据");
        } else {
            //    [self.mapView setRegion:MKCoordinateRegionMake(_locations.firstObject.coordinate, MKCoordinateSpanMake(self.deltaLa, self.deltaLo)) animated:YES]; 9 16 25 6 8 10 36 64 100
            UIImage *img = [UIImage heatMapWithRect:self.view.bounds boost:0.5 points:converArray weights:self.weights weightsAdjustmentEnabled:NO groupingEnabled:YES];
            self.heatImageView.image = img;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
   
    
}

- (void)blowUpOrShrink:(UIButton *)stepper
{
    // 每次增大0.2或者减小0.2
    if (stepper.tag == 0) {
        self.zoomRadio -= 0.2;
    } else {
        self.zoomRadio += 0.2;
    }
    [self resetHeatImageView];
}

#pragma mark - map delegate
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
////    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[self.locations count]];
////    for (int i = 0; i < self.locations.count; i++) {
////        CLLocation *location = [self.locations objectAtIndex:i];
////        CGPoint point = [self.mapView convertCoordinate:location.coordinate toPointToView:self.mapView];
////        [points addObject:[NSValue valueWithCGPoint:point]];
////    }
//    if (_pointArray) {
//        self.heatImageView.image = [UIImage heatMapWithRect:self.mapView.bounds boost:0.5 points:_pointArray weights:self.weights weightsAdjustmentEnabled:NO groupingEnabled:YES];
//    }
//    
//}
//
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
//}

@end
