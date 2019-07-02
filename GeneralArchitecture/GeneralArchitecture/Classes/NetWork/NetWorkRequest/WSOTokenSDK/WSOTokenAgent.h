//
//  WSOTokenAgent.h
//  WSOTokenDemo
//
//  Created by Sun Shijie on 2017/7/27.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

//Log输出
#ifdef DEBUG
#define TKLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define TKLog(...)
#endif

//回调
typedef void(^TokenSuccessBlock)(id response);
typedef void(^TokenFailureBlock)(NSURLSessionDataTask *task, NSError *error);

//错误类型
typedef NS_ENUM(NSUInteger, WSOTokenFailueCode) {
    
    WSOTokenFailueCodeRegisterDataFormat = 7000,
    WSOTokenFailueCodeRegisterTransformToDict,
    
    WSOTokenFailueCodeFetchSave,
    WSOTokenFailueCodeFetchDataFormat,
    WSOTokenFailueCodeFetchTransformToDict,
    
    WSOTokenFailueCodeRefreshSave,
    WSOTokenFailueCodeRefreshDataFormat,
    WSOTokenFailueCodeRefreshTransformToDict,
    
    WSOTokenFailueCodeNotExists,
    WSOTokenFailueCodeExpired,
};


@interface WSOTokenAgent : NSObject

@property (nonatomic, readwrite,copy) NSString *baseUrl;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

//获取单例
+ (WSOTokenAgent *)sharedAgent;

//登录 + 获取token 或者 直接获取token。
//内部存在一个判断：如果没有登录或登录失败，就先进行登录操作；如果登录已经成功了，就直接获取token
- (void)fetchTokenWithUserName:(NSString *)userName passWord:(NSString *)password tags:(NSArray *)tags scopes:(NSArray *)scopes success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;


//单独的获取token操作
- (void)fetchTokenWidthUserName:(NSString *)userName password:(NSString *)password andScopes:(NSArray *)scopes success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;


//刷新token操作
- (void)refreshTokenSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;

//修改密码
- (void)changePWWithOldPW:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;

- (void)userInfoSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;

//注销操作
- (void)unregisterSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;

//打印关于token所有信息
- (void)logTokenInfo;

//获取access token
- (NSString *)getAccessToken;

//获取权限数组
- (NSArray *)getScopeArray;

//验证当前Token是否过期
- (BOOL)isTokenExpired;

//清除token所有信息
- (void)clearAllInfo;

- (NSString *)getUserID;


- (NSString *)password;

@end
