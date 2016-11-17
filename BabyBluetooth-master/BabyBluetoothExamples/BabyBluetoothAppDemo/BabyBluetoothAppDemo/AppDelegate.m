//
//  AppDelegate.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/1.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "CoordinateDataModel.h"
#import "HeatMapViewController.h"
#import "MapViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    // 3f10080d0b251dd80bec21a42888055e001aff
//    CoordinateDataModel *model = [[CoordinateDataModel alloc] initWithString:@"3f10080d0b251dd80bec21a42888055e001aff"];
    // 如果使用美国站点，请加上下面这行代码：
    // [AVOSCloud setServiceRegion:AVServiceRegionUS];
//    3f100b0f072816d80bec1ba428d2020a0003ff
    CoordinateDataModel *m = [[CoordinateDataModel alloc] initWithString:@"3f100b0f07272ad80be71ba428bd030a00fdff"];
//    CoordinateDataModel *m2 = [[CoordinateDataModel alloc] initWithString:@"3f100b0f072820d80bfb1ba428ab020700f2ff"];
//    CoordinateDataModel *m3 = [[CoordinateDataModel alloc] initWithString:@"3f100b0f07282ad80bf11ba42871020600b7ff"];
//    CoordinateDataModel *m4 = [[CoordinateDataModel alloc] initWithString:@"3f100b0f072834d80b091ca42849020a00b6ff"];
    [AVOSCloud setApplicationId:@"rQQyTd1oV8uQXaBLHFElufJ1-gzGzoHsz" clientKey:@"FYQwJetEyNcvhprE2sbvY0ac"];

//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    NSString *documentPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[documentPath stringByAppendingPathComponent:@"temp2.plist"]];
//    NSArray *models = [CoordinateDataModel modelWithStringArray:array];
//    HeatMapViewController *heatMapVc = [[HeatMapViewController alloc] init];
////    MapViewController *heatMapVc = [[MapViewController alloc] init];
//    heatMapVc.models = models;
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:heatMapVc];
//    [self.window makeKeyAndVisible];
//    NSData *resualt = [NSKeyedArchiver archivedDataWithRootObject:@{
//                                                                    @"1" : @1
//                                                                    }];
    
//    NSArray *resualt = @[@1,@2,@3,@4];
//    
//    //            BOOL resualt = [self.dataSource writeToURL:[NSURL URLWithString:[documentPath stringByAppendingPathComponent:@"temp.plist"] ] atomically:YES];
//    BOOL isSuceess = [resualt writeToFile:[documentPath stringByAppendingPathComponent:@"temp.plist"] atomically:YES];
//    if (isSuceess) {
//        NSLog(@"success");
//    } else {
//        NSLog(@"failed");
//    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSLog(@"applicationWillEnterForeground");

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
