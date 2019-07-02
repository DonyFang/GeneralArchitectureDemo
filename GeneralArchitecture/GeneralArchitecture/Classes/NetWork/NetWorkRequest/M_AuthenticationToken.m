//
//  M_AuthenticationToken.m
//  MOffice
//
//  Created by 方冬冬 on 2018/4/20.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import "M_AuthenticationToken.h"
#import "UserPreferenceManager.h"
@interface M_AuthenticationToken()<NSURLSessionDelegate>
@property(nonatomic,strong)NSString *ST;
@property(nonatomic,strong)NSString *serial;
@property(nonatomic,strong)NSString *salt;
@property(nonatomic,strong)NSArray *resourcesArr;
@end
@implementation M_AuthenticationToken
{   
    AFHTTPSessionManager *_sessionManager;
}   
static id sharedAuthentication = nil;
+ (M_AuthenticationToken *)sharedAuthentication{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuthentication = [[self alloc] init];
    });
    return sharedAuthentication;
}

- (void)clearAllInfo
{
    self.ST = nil;
    self.serial = nil;
    self.salt = nil;
    self.resourcesArr = nil;
    [self clearDiskInfoCache];
}

- (void)clearDiskInfoCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UserPreferenceManager defaultManager] removeATInfo];
        [[UserPreferenceManager defaultManager] removeStInfo];
        [[UserPreferenceManager defaultManager] removeSaltInfo];
        [[UserPreferenceManager defaultManager] removeResourcesList];
        [[UserPreferenceManager defaultManager] removeUserSerialNum];
    });
}
- (NSString *)getST{
    //二级缓存
    if (self.ST.length > 0) {
        return self.ST;
    }else{
        NSString *st = [[NSUserDefaults standardUserDefaults] objectForKey:@"ST"];
        self.ST = st;
        return st;
    }
}

//获取盐
- (NSString *)getSalt
{
    //二级缓存
    if (self.salt.length > 0)
    {
        return self.salt;
    }else{
        NSString *salts = [[NSUserDefaults standardUserDefaults] objectForKey:@"salt"];
        self.salt = salts;
        return salts;
    }
}

//获取流水号
- (NSString *)getSerialNum
{
    //二级缓存
    if (self.serial.length > 0)
    {
        return self.serial;
    }else{
        NSString *serialNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNum"];
        self.serial = serialNum;
        return serialNum;
    }
}
//保存资源列表
- (NSArray *)getScopeArray{
    if (self.resourcesArr.count > 0) {
        return self.resourcesArr;
    }else{
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        NSArray *array=[userDefault objectForKey:@"resourcesList"];
        self.resourcesArr = array;
        return array;
    }
}
//认证接口调试
- (void)authenticationWithAppType:(NSString *)appType
              andDeviceIdentifier:(NSString *)deviceIdentifier
                          success:(TokenSuccessBlock)success
                          failure:(TokenFailureBlock)failure{
    //AFSessionManager config
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.requestSerializer.allowsCellularAccess = YES;
    _sessionManager.requestSerializer.timeoutInterval = 50;
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_sessionManager.securityPolicy setValidatesDomainName:NO];
    [_sessionManager.securityPolicy setAllowInvalidCertificates:YES];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
    // 构造URL地址
    NSString *url = [BASE_URL stringByAppendingString:@""];
    //iOS 获取语言环境
    //获取当前设备语言
    //iOS 获取语言环境
    //获取当前设备语言
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"currentlanguage = %@",currentLanguage);
    NSString *languageType = @"";
    if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
        languageType = @"zh_CN";
    }else{
        languageType = @"en_US";
    }
    NSDictionary *params = @{@"type":appType,@"imei":deviceIdentifier,@"lang":languageType};
    [_sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *responseObject) {
        NSDictionary *response = responseObject;

        NSLog(@"responseObject===%@",responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"responseObject====%@",responseObject);
            if (success) {
                success(responseObject);
            }   
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(task,error);
            }
        });
    }];
}


//用户登录失败。如果返回st过期 那么这个时候需要重新认证。
//用户登录成功的时候。流水号加1
- (void)loginWithUserAccount:(NSString *)userAccount
                 andPassword:(NSString *)password
            deviceIdentifier:(NSString *)deviceIdentifier
                       StStr:(NSString *)StStr
                serialNumber:(NSString *)serialNumber
                     success:(TokenSuccessBlock)success
                     failure:(TokenFailureBlock)failure{
    //AFSessionManager config
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.requestSerializer.allowsCellularAccess = YES;
    _sessionManager.requestSerializer.timeoutInterval = 50;
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_sessionManager.securityPolicy setValidatesDomainName:NO];
    [_sessionManager.securityPolicy setAllowInvalidCertificates:YES];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
    // 构造URL地址
    NSString *url = [BASE_URL stringByAppendingString:LoginURL];
    NSDictionary *params = @{@"st":StStr,@"imei":deviceIdentifier,@"serial":serialNumber,@"userName":userAccount,@"password":password};
    [_sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject====%@",responseObject);
        //登录成功的话。流水号加 1；
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

//判断字符串是否为空
- (BOOL) isBlankString:(id)string {
    if (!string)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"(null)"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string length]==0)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}


@end
