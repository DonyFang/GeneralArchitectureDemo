//
//  WWTLocation.m
//  Replenishment
//
//  Created by 尹星 on 2017/11/20.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import "WWTLocation.h"
#import <CoreLocation/CoreLocation.h>
//#import "LGAlertView.h"
#define Window [[UIApplication sharedApplication].delegate window]

@interface WWTLocation ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager             *locationManager;

@end

@implementation WWTLocation

- (void)p_findCurrentLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"未开启定位服务");
    }else if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager startUpdatingLocation];
    }else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)startUpdateLocationWithType:(WWTLocationType)type
{   
    //判断app定位功能状态
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            //[manager requestAlwaysAuthorization];//一直获取定位信息
            //[manager requestWhenInUseAuthorization];//使用的时候获取定位信息
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }else {
                [self.locationManager requestAlwaysAuthorization];
            }

            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"定位服务授权状态受限制，用户不能改变。");
            [self p_showTooltip];
            break;
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"定位服务授权被用户明确禁止");
            [self p_showTooltip];
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            if (type == WWTStartUpdateLocation) {
                [self p_findCurrentLocation];
            }
            NSLog(@"定位服务授权状态被用户允许在任何状态下获取位置信息");
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (type == WWTStartUpdateLocation) {
                [self p_findCurrentLocation];
            }
            NSLog(@"定位服务授权状态仅被允许在使用程序的时候");
        }
            break;
    }
}

- (void)p_showTooltip
{
    //1,在APP 一打开的时候 询问用户是否打开APP。  第二种 关闭定位提示，直接跳转到定位打开页面。
        
//    [LGAlertView setCancelButtonBackgroundColor:CustomColor(@"ffab00")];
//    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"打开“定位服务”来允许“运旺”确定您的位置"
//                                                        message:nil
//                                                          style:LGAlertViewStyleAlert
//                                                   buttonTitles:nil
//                                              cancelButtonTitle:@"取消"
//                                         destructiveButtonTitle:@"设置"
//                                                  actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
//                                                  }
//                                                  cancelHandler:^(LGAlertView *alertView) {
//                                                  }
//                                             destructiveHandler:^(LGAlertView *alertView) {
//                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//                                             }];
//    [alertView showAnimated:YES completionHandler:nil];


        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //UIAlertControllerStyleAlert视图在中央
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [Window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - <CLLocationManagerDelegate>
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"longitude = %lf, latitude = %lf",locations.lastObject.coordinate.longitude,locations.lastObject.coordinate.latitude);
    
    CLLocation *newLocation = [locations lastObject];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                
                NSString *city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                if (self.locationBlock) {
                    self.locationBlock(placemark.addressDictionary, locations.lastObject.coordinate.longitude,locations.lastObject.coordinate.latitude);
                }
                NSLog(@"location_city --> %@ %@",city,placemark.addressDictionary);
            }else if ([placemarks count] == 0) {
                NSLog(@"定位城市失败");
            }else {
                NSLog(@"请检查您的网络");
            }
        }
    }];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败");
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"定位失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [Window.rootViewController presentViewController:alertC animated:YES completion:nil];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - 懒加载
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

@end
