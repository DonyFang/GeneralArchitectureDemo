//
//  ControllersManager.h
//  LingTouNiaoZF
//
//  Created by LiuFeifei on 16/10/27.
//  Copyright © 2016年 LiuJie. All rights reserved.
//

/**
    控制各controller的跳转
 */
#import <Foundation/Foundation.h>

@interface ControllersManager : NSObject
singleton_interface(ControllersManager)
@property (nonatomic, strong) UIViewController * rootViewController;
//切换根实图控制器
- (void)setupProjectRootViewController;

#pragma mark - about user
- (void)loginControllerAnimated:(BOOL)animated;
- (void)registerControllerAnimated:(BOOL)animated;
//登出
- (void)loginOut;


@end
