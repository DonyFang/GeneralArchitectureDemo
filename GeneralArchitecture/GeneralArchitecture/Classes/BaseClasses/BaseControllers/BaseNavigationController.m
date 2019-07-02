//
//  BaseNavigationController.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()
@property (strong, nonatomic) UIView * navigationBottomLine;

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 透明度
    self.navigationBar.translucent = NO;
    // 背景色
    self.barBackgroundColor = [UIColor whiteColor];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //藏旧
    [self hideBorderInView:self.navigationBar];
    //添新
    [self.navigationBar addSubview:self.navigationBottomLine];
}

#pragma mark - getter methods
#pragma mark -- 自定义的底部线条
- (UIView *)navigationBottomLine
{
    if (!_navigationBottomLine) {
        _navigationBottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, kGeneralSize, SCREEN_WIDTH, 1.0 / kScreenScale)];
        _navigationBottomLine.backgroundColor = [UIColor colorWithHex:0xD8D8D8];
    }
    return _navigationBottomLine;
}

#pragma mark - private methods
#pragma mark -- 查找系统navigationbar底部线条并隐藏
- (void)hideBorderInView:(UIView *)view{

    if ([view isKindOfClass:[UIImageView class]]
        && view.frame.size.height <= 1) {
        view.hidden = YES;
    }
    for (UIView *subView in view.subviews) {
        [self hideBorderInView:subView];
    }
}

#pragma mark -- 隐藏自定义底部线条
- (void)hideBorder:(BOOL)hiden
{
    self.navigationBottomLine.hidden = hiden;
}

#pragma mark setter methods
- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor
{
    _barBackgroundColor = barBackgroundColor;
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:barBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.navigationBottomLine.backgroundColor = borderColor;
}

#pragma mark override
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}


#pragma mark - overwrite
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
