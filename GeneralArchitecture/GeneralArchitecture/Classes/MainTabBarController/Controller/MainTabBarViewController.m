//
//  MainTabBarViewController.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "BaseNavigationController.h"

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

@interface MainTabBarViewController ()
            
@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *childItemsArray = @[
                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"微信",
                                   kImgKey    : @"tabbar_mainframe",
                                   kSelImgKey : @"tabbar_mainframeHL"},

                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"通讯录",
                                   kImgKey    : @"tabbar_contacts",
                                   kSelImgKey : @"tabbar_contactsHL"},

                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"发现",
                                   kImgKey    : @"tabbar_discover",
                                   kSelImgKey : @"tabbar_discoverHL"},

                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"我",
                                   kImgKey    : @"tabbar_me",
                                   kSelImgKey : @"tabbar_meHL"} ];

    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = [NSClassFromString(dict[kClassKey]) new];
        vc.title = dict[kTitleKey];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        UITabBarItem *item = nav.tabBarItem;
        item.title = dict[kTitleKey];
        item.image = [UIImage imageNamed:dict[kImgKey]];
        item.selectedImage = [[UIImage imageNamed:dict[kSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName : Global_tintColor} forState:UIControlStateSelected];
        [self addChildViewController:nav];
    }];

}


/**
 *  添加一个子控制器
 *
 *  @param title       控制器标题
 *  @param chlidVc     子控制器
 *  @param image       图片
 *  @param selectImage 选中的图片
 */
- (void)addClildVCWithTitle:(NSString *)title
             viewController:(UIViewController *)chlidVc
                      image:(NSString *)image
                selectImage:(NSString *)selectImage {
    //给传进来的控制器添加导航控制器
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:chlidVc];
    //添加为子控制器
    [self addChildViewController:nav];
}
@end
