//
//  MapViewController.m
//  BabyBluetoothAppDemo
//
//  Created by ywl on 16/9/14.
//  Copyright © 2016年 刘彦玮. All rights reserved.
//

#import "MapViewController.h"
#import "UIImage+CCHeatMap.h"
#import "CoordinateDataModel.h"
@interface MapViewController () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *heatImageView;
@property (nonatomic, strong) NSMutableArray<CLLocation *> *locations;
@property (nonatomic, strong) NSMutableArray *weights;
@property (nonatomic, assign) CGFloat deltaLa;
@property (nonatomic, assign) CGFloat deltaLo;

@property (nonatomic, strong) NSMutableArray *pointArray;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mapView];
    _mapView.delegate = self;
    
    self.heatImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_heatImageView];
    
    _locations = [NSMutableArray array];
    _weights = [NSMutableArray array];
    _pointArray = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat maxLa = 0.01;
    CGFloat minLa = 1000;
    CGFloat maxLo = 0.01;
    CGFloat minLo = 1000;
    
    for (CoordinateDataModel *model in self.models) {
        if (model.latitude < 30 || model.longitude < 100) {
            return;
        }
        CLLocation *location = [[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude];
        NSLog(@"%@", location);
//        [_pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(model.latitude, model.longitude)]];
        [_locations addObject:location];
        [_weights addObject:@1];
        
//        if (model.latitude > maxLa) {
//            maxLa = model.latitude;
//            
//            
//        }
//        
//        if (model.latitude < minLa ) {
//            minLa = model.latitude;
//        }
//        
//        if (model.longitude > maxLo) {
//            maxLo = model.longitude;
//        }
//        
//        if (model.longitude < minLo) {
//            minLo = model.longitude;
//        }
    }

}


#pragma mark - map delegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[self.locations count]];
    for (int i = 0; i < self.locations.count; i++) {
        CLLocation *location = [self.locations objectAtIndex:i];
        CGPoint point = [self.mapView convertCoordinate:location.coordinate toPointToView:self.mapView];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
//    if (_pointArray) {
        self.heatImageView.image = [UIImage heatMapWithRect:self.mapView.bounds boost:0.5 points:points weights:self.weights weightsAdjustmentEnabled:NO groupingEnabled:YES];
//    }

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
}

@end
