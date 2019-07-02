//
//  AppDelegate+UpdatingProgram.m
//  MOffice
//
//  Created by 方冬冬 on 2019/3/13.
//  Copyright © 2019年 ChinaSoft. All rights reserved.
//

#import "AppDelegate+UpdatingProgram.h"
#import "M_AuthenticationToken.h"
@implementation AppDelegate (UpdatingProgram)
- (void)checkUpdateIsShowPopView
{    
    //请求更新接口
//    NSLog(@"%@",CurrentVersion);
//    [[M_AuthenticationToken sharedAuthentication] apppVersionCheckWithAPPType:@"21" VERSION_CODE:CurrentVersion success:^(id response) {
//        NSString *status = [NSString stringWithFormat:@"%@",response[@"status"]];
//        NSString *lastVersion = [NSString stringWithFormat:@"%@",response[@"lastVersion"]];
//        [self handleDifferentcaseswithFlage:status withUrl:lastVersion];
//        //检测是否需要更新 1最新版（不用更新），2可用非最新（可更新可不更新），3不可用（强制更新）
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//    }];
}
//处理是否更新的场景
- (void)handleDifferentcaseswithFlage:(NSString *)flag withUrl:(NSString *)url{
    NSInteger tags = [flag integerValue];
    switch (tags) {
        case 1://不做处理
            break;
        case 2:
            [self showTipMsgWithMSG:@"" withDownUrl:url  forceUpdate:NO];//用户点击取消不在显示弹出框
            break;
        case 3:
            [self showTipMsgWithMSG:@"" withDownUrl:url  forceUpdate:YES];
            break;
        default:
            break;
    }
}
- (void)showTipMsgWithMSG:(NSString *)msg withDownUrl:(NSString *)downUrl forceUpdate:(BOOL)forceUpdate{
    if (forceUpdate) {
        //弹出提示框 提示是否下载
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"soft_update" message:@"soft_update_info" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sureClick =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击确定按钮 弹出下载框
            /**
             跳转到下载页
             */
            NSString *upUrl = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@",MyAPPID];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upUrl] options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:^(BOOL success) {

                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upUrl]];
            }   
        }];
        UIAlertAction * cancleClick =[UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            exit(0);//强制退出
        }];
        [alert addAction:sureClick];
        [alert addAction:cancleClick];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }else{//状态等于2的时候 非强制更新的时候
        if (![[[UserPreferenceManager defaultManager] getUserCancel] isEqualToString:@"YES"]) {
            //弹出提示框 提示是否下载
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"soft_update" message:@"soft_update_info" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * sureClick =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击确定按钮 弹出下载框
                /**
                 跳转到下载页
                 */
                NSString *upUrl = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@",MyAPPID];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upUrl] options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:^(BOOL success) {

                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upUrl]];
                }
            }];
            UIAlertAction * cancleClick =[UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //非强制更新的时候 用户点击取消 不再提示弹出框
                [[UserPreferenceManager defaultManager] saveUserCancelOperation:@"YES"];
            }];
            [alert addAction:sureClick];
            [alert addAction:cancleClick];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];

        }
    }
}
@end
