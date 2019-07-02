//
//  ControllersManager.m
//  LingTouNiaoZF
//
//  Created by LiuFeifei on 16/10/27.
//  Copyright © 2016年 LiuJie. All rights reserved.
//

#import "ControllersManager.h"
#import "BaseNavigationController.h"
//#import "ProjectRootController.h"
//#import "MeRootController.h"
//#import "UserLoginController.h"
//#import "UserRetrieveController.h"
#import "UserRegisterController.h"
//#import "AboutRootController.h"
//#import "FeedbackController.h"
//#import "LoginModel.h"
//#import "UIAlertView+Block.h"
//#import "SHRootViewController.h"
#import "LoginViewController.h"
@interface ControllersManager ()<UIAlertViewDelegate>

@end

@implementation ControllersManager

singleton_implementation(ControllersManager)

#pragma mark - 设置根视图
- (void)setupProjectRootViewController
{


}

#pragma mark - private methods
- (void)pushToViewController:(UIViewController *)viewController
{
    [self pushToViewController:viewController animated:YES];
}

- (void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController * nav = (UINavigationController *)self.rootViewController;
        for (UIViewController * controller in nav.childViewControllers) {
            if ([controller isKindOfClass:[viewController class]]) {
                [nav popToViewController:controller animated:animated];
                return;
            }
        }
        UIViewController * topViewController = nav.topViewController;
        [topViewController.navigationController pushViewController:viewController animated:animated];
    } else {
        BaseNavigationController * navController = [[BaseNavigationController alloc] initWithRootViewController:viewController];
        [self.rootViewController presentViewController:navController animated:animated completion:nil];
    }
}
- (void)loginOut
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //清除登录时的敏感数据 跳转到登陆页
        [self cleadSensitiveData];
        [self loginControllerAnimated:YES];
    });
}

- (void)cleadSensitiveData{
    [[UserPreferenceManager defaultManager] removeUserLoginStatues];

}
- (void)loginControllerAnimated:(BOOL)animated
{
    LoginViewController * loginController = [[LoginViewController alloc] init];
    [self pushToViewController:loginController animated:animated];
}

//- (void)loginController:(VoidBlock)finishBlock
//{
//    [self loginController:finishBlock animated:YES];
//}

- (void)resetPassword
{
//    BaseNavigationController * retrieveNav = [[BaseNavigationController alloc] initWithRootViewController:[[UserRetrieveController alloc] initWithRetrieveType:kRetrieveTypeOfReset]];
//        if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
//            UINavigationController * nav = (UINavigationController *)self.rootViewController;
//            [nav.visibleViewController presentViewController:retrieveNav animated:YES completion:nil];
//        }
}

- (void)retrievePassword
{
//    BaseNavigationController * retrieveNav = [[BaseNavigationController alloc] initWithRootViewController:[[UserRetrieveController alloc] init]];
//    if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController * nav = (UINavigationController *)self.rootViewController;
//        [nav.visibleViewController presentViewController:retrieveNav animated:YES completion:nil];
//    }
}

- (void)registerControllerAnimated:(BOOL)animated
{
    UserRegisterController * registerController = [[UserRegisterController alloc] init];
    [self pushToViewController:registerController animated:animated];
}


@end
