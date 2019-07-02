//
//  M_AuthenticationToken.h
//  MOffice
//
//  Created by 方冬冬 on 2018/4/20.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
//回调
typedef void(^TokenSuccessBlock)(id response);
typedef void(^TokenFailureBlock)(NSURLSessionDataTask *task, NSError *error);

@interface M_AuthenticationToken : NSObject
+ (M_AuthenticationToken *)sharedAuthentication;

/**
 认证  ===获取ST
 @param appType APP 类型
 @param deviceIdentifier 设备唯一标识UUID
 */
- (void)authenticationWithAppType:(NSString *)appType
              andDeviceIdentifier:(NSString *)deviceIdentifier
                          success:(TokenSuccessBlock)success
                          failure:(TokenFailureBlock)failure;

@property (nonatomic, readwrite,copy) NSString *baseUrl;

/**
 用户登录接口
 @param userAccount 用户账号
 @param password 密码
 @param deviceIdentifier 设备UUID
 @param StStr 认证的ST
 @param serialNumber 流水号
 */
- (void)loginWithUserAccount:(NSString *)userAccount
                 andPassword:(NSString *)password
            deviceIdentifier:(NSString *)deviceIdentifier
                       StStr:(NSString *)StStr
                serialNumber:(NSString *)serialNumber
                     success:(TokenSuccessBlock)success
                     failure:(TokenFailureBlock)failure;

//清除所有保存的信息
- (void)clearAllInfo;
        
//获取ST
- (NSString *)getST;

//获取盐
- (NSString *)getSalt;

//获取流水号
- (NSString *)getSerialNum;
//获取权限数组
- (NSArray *)getScopeArray;

@end
