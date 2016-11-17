//
//  QZNavigationController.m
//  QQZQ
//
//  Created by ywl on 16/1/4.
//  Copyright © 2016年 cafuc. All rights reserved.
//

#import "QZNavigationController.h"


@interface QZNavigationController () 
@property (nonatomic, strong) UIButton *backBtn;
@end

@implementation QZNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navigationBarAppearance];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)navigationBarAppearance
{
    UINavigationBar *bar = [UINavigationBar appearance];
    //  nc.navigationBar.translucent = NO;
    //去掉导航条的半透明
//    bar.barTintColor = RGBACOLOR(45, 45, 45, 1);
//    bar.barTintColor = [UIColor colorWithHexString:@"#6d9c0b"];
    bar.translucent = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    
    [bar setTitleTextAttributes:dict];
    
    UIBarButtonItem *item = [UIBarButtonItem appearance];
//    UIImage *backImage = [UIImage imageNamed:@"back"];
//    backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width - 1, 0, 1)];
//    [item setBackButtonBackgroundImage:backImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [item setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _backBtn.titleLabel.hidden = YES;
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        _backBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//        CGFloat btnW = SCREEN_WIDTH > 375.0 ? 50 : 44;
//        _backBtn.frame = CGRectMake(0, 0, btnW, 40);
        [_backBtn sizeToFit];
    }
    return _backBtn;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    viewController.navigationItem.hidesBackButton = YES;
//    if (self.childViewControllers.count > 0) {
//        [UINavigationBar appearance].backItem.hidesBackButton = NO;
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
////        [viewController.navigationItem setLeftMargin:10];
////        [viewController.navigationItem setRightMargin:10];
//    }
    if (self.childViewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:YES];
    
}


- (void)backBtnClick
{
    [self popViewControllerAnimated:YES];
}

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated
//{
//    UIViewController *vc = [super popViewControllerAnimated:animated];
//    if (self.viewControllers.count == 1) {
//        self.tabBarController.tabBar.hidden = NO;
//    }
//    
//    return vc;
//}


@end
