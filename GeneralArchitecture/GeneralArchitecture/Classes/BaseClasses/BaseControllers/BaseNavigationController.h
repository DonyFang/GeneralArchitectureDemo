//
//  BaseNavigationController.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController
@property (nonatomic, strong) UIColor * barBackgroundColor;
@property (nonatomic, strong) UIColor * borderColor;
#pragma mark 隐藏底部线条
- (void)hideBorder:(BOOL)hiden;
@end
