//
//  BaseViewController+TipMessage.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/5/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseViewController+TipMessage.h"
@interface BaseViewController()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) MBProgressHUD *progressView;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@end

@implementation BaseViewController (TipMessage)
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showProgressView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.indicator==nil) {
            self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.indicator.color = [UIColor redColor];
            self.indicator.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMidY(self.view.bounds));
            self.view.userInteractionEnabled = NO;
            [self.view addSubview:self.indicator];
        }
        [self.indicator startAnimating];
    });
}

- (void)showProgressView:(UIColor *)color{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.indicator==nil) {
            self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.indicator.color = color;
            self.indicator.center =    CGPointMake(self.view.frame.size.width/2.0, CGRectGetMidY(self.view.bounds));
            [self.view addSubview:self.indicator];
        }
        [self.indicator startAnimating];
    });
}



-(void)dismissProgressView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        self.indicator = nil;
    });
}

-(void)showTipWithMessage:(NSString *)aMessage{
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    tip.mode = MBProgressHUDModeText;
    tip.margin = 10.f;

    //    tip.yOffset = 150.f;
    tip.detailsLabelText = aMessage;
    tip.labelFont = [UIFont systemFontOfSize:12.0];
    [tip show:YES];
    [tip hide:YES afterDelay:1.5];
}


- (void)showLoadingWithMessage:(NSString *)aMessage
{
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    tip.mode = MBProgressHUDModeIndeterminate;
    tip.margin = 10.f;
    tip.labelText = aMessage;
    tip.labelFont = [UIFont systemFontOfSize:12.0];
    [tip show:YES];
}

- (void)hiddenLoading
{
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    tip.mode = MBProgressHUDModeIndeterminate;
    tip.margin = 10.f;
    tip.labelFont = [UIFont systemFontOfSize:12.0];
    [tip hide:YES];
    [tip removeFromSuperview];
}

@end
