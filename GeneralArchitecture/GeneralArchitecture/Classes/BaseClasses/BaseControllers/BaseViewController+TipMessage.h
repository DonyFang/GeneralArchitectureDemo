//
//  BaseViewController+TipMessage.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/5/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseViewController.h"
#import  <MBProgressHUD.h>
@interface BaseViewController (TipMessage)
- (void)back;
- (void)showProgressView;
- (void)dismissProgressView;
- (void)showTipWithMessage:(NSString *)aMessage;
- (void)showLoadingWithMessage:(NSString *)aMessage;
- (void)hiddenLoading;
- (void)showProgressView:(UIColor *)color;
@end
