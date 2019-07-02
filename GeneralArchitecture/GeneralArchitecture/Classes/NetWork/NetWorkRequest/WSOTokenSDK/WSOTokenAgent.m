//
//  WSOTokenAgent.m
//  WSOTokenDemo
//
//  Created by Sun Shijie on 2017/7/27.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSOTokenAgent.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif


@interface WSOTokenAgent()<NSURLSessionDelegate>

@property (nonatomic, readwrite, copy) NSString *user_id;
@property (nonatomic, readwrite, copy) NSString *password;
@property (nonatomic, readwrite, copy) NSString *access_token;
@property (nonatomic, readwrite, copy) NSString *refresh_token;
@property (nonatomic, readwrite, copy) NSString *token_type;
@property (nonatomic, readwrite, copy) NSArray  *scopesArr;
@property (nonatomic, readwrite, strong) NSDate *expiredDate;

@end


@implementation WSOTokenAgent{
    AFHTTPSessionManager *_manager;
}


+ (WSOTokenAgent *)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)fetchTokenWithUserName:(NSString *)userName passWord:(NSString *)password tags:(NSArray *)tags scopes:(NSArray *)scopes success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;
{

    if ([self hasCientIDAndClientSecrete]) {
        //如果已经有client_id和client_secrete，就可以直接请求token
        [self fetchTokenWidthUserName:userName password:password andScopes:scopes success:^(id response) {
            if(success){
                success(response);
            }
        } failure:^(NSURLSessionDataTask *task,NSError *error) {
            if (failure) {
                failure(task,error);
            }
        }];

    }else{
        //如果没有client_id和client_secrete，就需要先通过注册来获得client_id和client_secrete
        [self registerWithUserName:userName passWord:password andTags:tags scopes:scopes success:^ (id response) {
            if(success){
                success(response);
            }   
        } failure:^(NSURLSessionDataTask *task,NSError *error) {
            if (failure) {
                failure(task,error);
            }
        }];
    }
}


- (void)registerWithUserName:(NSString *)userName passWord:(NSString *)password andTags:(NSArray *)tags scopes:(NSArray *)scopes success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure;
{
    // 构造URL地址
    NSString*url = [self.baseUrl stringByAppendingString:@"/api-application-registration/register"];
    TKLog(@"*********** 开始注册:%@",url);
    bool bool_false = false;
    
    NSDictionary *params = @{
                             @"applicationName":[self deviceName],
                             @"consumerKey":[NSNull null],
                             @"consumerSecret":[NSNull null],
                             @"tags":tags,
                             @"isAllowedToAllDomains":@(bool_false),
                             @"isMappingAnExistingOAuthApp":@(bool_false),
                             @"allowedToAllDomains":@(bool_false),
                             @"mappingAnExistingOAuthApp":@(bool_false)
                             };
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10;
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
//    [_manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
//    [_manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[self authorizationStringWithStr1:userName str2:password withPrefix:@"Basic"] forHTTPHeaderField:@"Authorization"];
    [_manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            
            id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            
            if ([object isKindOfClass:[NSDictionary class]]) {
                TKLog(@"*********** 注册返回成功:%@",object);
                
                NSString *clientID = [object objectForKey:@"client_id"];
                NSString *clientSecrete = [object objectForKey:@"client_secret"];
                [self storeClientID:clientID];
                [self storeClientSecret:clientSecrete];
                
                [self fetchTokenWidthUserName:userName password:password andScopes:scopes success:^(id response){
                    if (success) {
                        success(responseObject);
                    }
                } failure:^(NSURLSessionDataTask *task,NSError *error) {
                    if (failure) {
                        failure(task,error);
                    }
                }];
                
            }else{
                
                error = [NSError errorWithDomain:@"注册失败：从Data到Dictionary转化失败" code:WSOTokenFailueCodeRegisterTransformToDict userInfo:nil];
                TKLog(@"*********** error:%@",error);
                if (failure) {
                    failure(task,error);
                }
                
            }
        }else{
            
            error = [NSError errorWithDomain:@"注册失败：返回数据不是NSData格式" code:WSOTokenFailueCodeRegisterDataFormat userInfo:nil];
            TKLog(@"*********** error:%@",error);
            if (failure) {
                failure(task,error);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        
        if (httpResponse.statusCode == 401) {
            NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSString *message = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
            NSError * error_401 = [NSError errorWithDomain:message code:401 userInfo:nil];
            
            TKLog(@"*********** 注册失败 code 401 error:%@",error_401);
            if (failure) {
                failure(task,error_401);
            }
            
        }else{
            
            TKLog(@"*********** 注册失败 error:%@",error);
            if (failure) {
                failure(task,error);
            }
        }
        
    }];
}

- (void)changePWWithOldPW:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure{
    
    // 构造URL地址
    NSString *startUrl = [self.baseUrl stringByAppendingString:@"/api/device-mgt/v1.0/users/credentials"];
    TKLog(@"*********** 开始修改密码:%@",startUrl);
    
    NSDictionary *params = @{@"oldPassword":oldPassword,@"newPassword":newPassword};
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
     _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
     _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
     _manager.requestSerializer = [AFJSONRequestSerializer serializer];
     _manager.requestSerializer.timeoutInterval = 10;
     _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
     _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self getAccessToken]] forHTTPHeaderField:@"Authorization"];
    
    
    [_manager PUT:startUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSString*result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (success) {
                TKLog(@"*********** 修改密码成功:%@",result);
                success(result);
            }
        }else{
            
            error = [NSError errorWithDomain:@"修改密码失败：返回数据不是NSData格式" code:WSOTokenFailueCodeFetchDataFormat userInfo:nil];
            TKLog(@"*********** 修改密码失败:%@",error);
            if (failure) {
                failure(task,error);
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TKLog(@"*********** 修改密码失败%@",error);
        if (failure) {
            failure(task,error);
        }
    }];
}

- (void)userInfoSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure{

    // 构造URL地址
    NSString *startUrl = [self.baseUrl stringByAppendingString:@"/userinfo"];
    TKLog(@"*********** 开始获取用户信息:%@",startUrl);
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10;
    _manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self getAccessToken]] forHTTPHeaderField:@"Authorization"];
    
    
    [_manager GET:startUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError * error = nil;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            
                if (success) {
                    success(responseObject);
                }
            
        }else{
            
            error = [NSError errorWithDomain:@"获取用户信息失败：返回数据不是NSData格式" code:WSOTokenFailueCodeFetchDataFormat userInfo:nil];
            TKLog(@"*********** 获取用户信息失败:%@",error);
            if (failure) {
                failure(task,error);
            }
            
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TKLog(@"*********** 获取用户信息失败%@",error);
        if (failure) {
            failure(task,error);
        }        
    }];
    
}

- (void)fetchTokenWidthUserName:(NSString *)userName password:(NSString *)password andScopes:(NSArray *)scopes success:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure
{
    // 构造URL地址
    NSString *startUrl = [self.baseUrl stringByAppendingString:@"/token?"];
    
    NSMutableString *mUrl = [startUrl mutableCopy];
    [mUrl appendString:[NSString stringWithFormat:@"username=%@",userName]];
    [mUrl appendString:@"&scope=default appm:read"];
    
    NSString *rightsString = [self generateRightsStringWidthScopesArr:scopes];
    [mUrl appendString:rightsString];
    [mUrl appendString:[NSString stringWithFormat:@"&password=%@&grant_type=password&=",password]];
    TKLog(@"*********** 开始获取token:%@",mUrl);
    
    //    NSString *charactersToEscape = @"!@#$^%*+,;'\"`<>()[]{}\\|";
    //    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    //    NSString *url= [mUrl stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSString *url = [mUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{};
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10;
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *storedClientID = [self getClientID];;
    NSString *storedClientSecrete = [self getClientSecret];
    NSString *authorizedString = [self authorizationStringWithStr1:storedClientID str2:storedClientSecrete withPrefix:@"Basic"];
    
    [_manager.requestSerializer setValue:authorizedString forHTTPHeaderField:@"Authorization"];
    
    [_manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            if ([object isKindOfClass:[NSDictionary class]]) {
                
                NSString *scopesStr = [object objectForKey:@"scope"];
                self.scopesArr = [scopesStr componentsSeparatedByString:@" "];
                
                self.user_id = userName;
                self.password = password;
                
                [self storeUserID:self.user_id];
                [self storePassword:self.password];
                
                
                
                //存入内存
                self.access_token = [object objectForKey:@"access_token"];
                self.refresh_token = [object objectForKey:@"refresh_token"];
                NSInteger expires_in = [[object objectForKey:@"expires_in"] integerValue] + 8 * 3600;
                self.expiredDate =  [[NSDate date] dateByAddingTimeInterval:expires_in];
                
                //存入磁盘
                [self storeAccessToken:self.access_token];
                [self storeRefreshToken:self.refresh_token];
                [self storeExpiredDate:self.expiredDate];
                
                self.token_type = [object objectForKey:@"token_type"];
                
                if (self.access_token.length > 0 && self.refresh_token.length > 0) {
                    
                    TKLog(@"*********** 获取access_token和refresh_token成功");
                    [self logTokenInfo];
                    if (success) {
                        success(responseObject);
                    }
                    
                }else{
                    
                    error = [NSError errorWithDomain:@"获取token失败：保存access_token和refresh_token失败" code:WSOTokenFailueCodeFetchSave userInfo:nil];
                    TKLog(@"*********** 获取token失败:%@",error);
                    if (failure) {
                        failure(task,error);
                    }
                }
                
            }else{
                
                error = [NSError errorWithDomain:@"获取token失败：从Data到Dictionary转化失败" code:WSOTokenFailueCodeFetchTransformToDict userInfo:nil];
                TKLog(@"*********** 获取token失败:%@",error);
                if (failure) {
                    failure(task,error);
                }
            }
            
        }else{
            
            error = [NSError errorWithDomain:@"获取token失败：返回数据不是NSData格式" code:WSOTokenFailueCodeFetchDataFormat userInfo:nil];
            TKLog(@"*********** 获取token失败:%@",error);
            if (failure) {
             failure(task,error);
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TKLog(@"*********** 获取token失败:%@",error);
        if (failure) {
             failure(task,error);
        }
        
    }];
}

- (void)refreshTokenSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure
{
    // 构造URL地址
    NSString *startUrl = [self.baseUrl stringByAppendingString:@"/token?"];
    NSMutableString *mUrl = [startUrl mutableCopy];
    [mUrl appendString:[NSString stringWithFormat:@"refresh_token=%@",[self getRefreshToken]]];
    [mUrl appendString:@"&grant_type=refresh_token&scope=PRODUCTION"];
    NSString *url = [mUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    TKLog(@"*********** 开始刷新token:%@",url);
    NSDictionary *params = @{};
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10;
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *storedClientID = [self getClientID];;
    NSString *storedClientSecrete = [self getClientSecret];
    NSString *authorizedString = [self authorizationStringWithStr1:storedClientID str2:storedClientSecrete withPrefix:@"Basic"];
    
    [_manager.requestSerializer setValue:authorizedString forHTTPHeaderField:@"Authorization"];
    
    [_manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            
            id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            if ([object isKindOfClass:[NSDictionary class]]) {
                
                NSString *scopesStr = [object objectForKey:@"scope"];
                self.scopesArr = [scopesStr componentsSeparatedByString:@" "];
                //                if ( (!self.scopesArr) || [self.scopesArr count] == 0 || [self.scopesArr count] == 1) {
                //                    error = [NSError errorWithDomain:@"刷新token：没有权限" code:WSOTokenFailueCodeRefreshSave userInfo:nil];
                //                    TKLog(@"*********** 刷新token失败:%@",error);
                //                    failure(task,error);
                //                    return;
                //                }
                
                //存入内存
                self.access_token = [object objectForKey:@"access_token"];
                self.refresh_token = [object objectForKey:@"refresh_token"];
                NSInteger expires_in = [[object objectForKey:@"expires_in"] integerValue] + 8*3600;
                self.expiredDate =  [[NSDate date] dateByAddingTimeInterval:expires_in];
                
                //存入磁盘
                [self storeAccessToken:self.access_token];
                [self storeRefreshToken:self.refresh_token];
                [self storeExpiredDate:self.expiredDate];
                
                self.token_type = [object objectForKey:@"token_type"];
                
                
                if (self.access_token.length > 0 && self.refresh_token.length > 0) {
                    
                    TKLog(@"*********** 刷新token成功 | new token info:");
                    [self logTokenInfo];
                    if (success) {
                        success(responseObject);
                    }
                    
                }else{
                    
                    
                    error = [NSError errorWithDomain:@"刷新token：返回并保存数据失败" code:WSOTokenFailueCodeRefreshSave userInfo:nil];
                    TKLog(@"*********** 刷新token失败:%@",error);
                    if (failure) {
                        failure(task,error);
                    }
                }
                
            }else{
                
                NSError *error = [NSError errorWithDomain:@"刷新token失败：从Data到Dictionary转化失败" code:WSOTokenFailueCodeRefreshTransformToDict userInfo:nil];
                TKLog(@"*********** 刷新token失败:%@",error);
                if (failure) {
                    failure(task,error);
                }
                
            }
        }else{
            
            NSError *error = [NSError errorWithDomain:@"刷新token失败：返回数据不是NSData格式" code:WSOTokenFailueCodeRefreshDataFormat userInfo:nil];
            TKLog(@"*********** 刷新token失败:%@",error);
            if (failure) {
                failure(task,error);
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TKLog(@"*********** 刷新token失败:%@",error);
        if (failure) {
             failure(task,error);
        }
        
    }];
    
}

- (void)unregisterSuccess:(TokenSuccessBlock)success failure:(TokenFailureBlock)failure{
    
    // 构造URL地址
    NSString *startUrl = [self.baseUrl stringByAppendingString:@"/api-application-registration/unregister?applicationName="];
    NSMutableString *mUrl = [startUrl mutableCopy];
    [mUrl appendString:[self deviceName]];
    
    NSString *url = [mUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    TKLog(@"*********** 开始注销:%@",url);
    
    NSDictionary *params = @{};
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10;
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/JavaScript",@"text/html",@"text/plain",nil];
    
    [_manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *authorizedString = [@"Bearer" stringByAppendingString:[NSString stringWithFormat:@" %@",[self getAccessToken]]];
    
    [_manager.requestSerializer setValue:authorizedString forHTTPHeaderField:@"Authorization"];
    
    [_manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        TKLog(@"*********** 注销成功");
        if (success) {
            success(responseObject);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TKLog(@"*********** 注销失败 错误：%@",error);
        if (failure) {
            failure(task,error);
        }
    }];
    
}





- (void)logTokenInfo{
    
    TKLog(@"*********** Token Info :\n *********** access_token: %@ \n *********** refresh_token %@ \n *********** expires_date:%@ \n *********** scopesArr:%@",[self getAccessToken],[self getRefreshToken],[NSString stringWithFormat:@"%@",[self getExpiredDate]],self.scopesArr);
}



- (BOOL)isTokenExpired{
    
    
    if (![self getExpiredDate]) {
        return YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *oneDayStr = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:8*3600]];
    NSString *anotherDayStr = [dateFormatter stringFromDate:self.expiredDate];
    
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        //NSLog(@"oneDay比 anotherDay时间晚");
        return YES;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"oneDay比 anotherDay时间早");
        return NO;
    }
    //NSLog(@"两者时间是同一个时间");
    return YES;
    
}


#pragma Private Methods

//存储Token相关数据

- (void)storeUserID:(NSString *)userID{
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"user_id"];
}

- (void)storePassword:(NSString *)password{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
}

- (void)storeClientID:(NSString *)clientID{
    [[NSUserDefaults standardUserDefaults] setObject:clientID forKey:@"client_id"];
}

- (void)storeClientSecret:(NSString *)clientSecret{
    [[NSUserDefaults standardUserDefaults] setObject:clientSecret forKey:@"client_secrete"];
}

- (void)storeAccessToken:(NSString *)accessToken{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
}

- (void)storeRefreshToken:(NSString *)refreshToken{
    [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:@"refresh_token"];
}

- (void)storeExpiredDate:(NSDate *)expiredDate{
    [[NSUserDefaults standardUserDefaults] setObject:expiredDate forKey:@"expired_date"];
}


//获取Token相关数据


- (NSString *)getUserID{
    
    if (_user_id.length > 0) {
        return _user_id;
    }else{
        NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        _user_id = user_id;
        return _user_id;
    }
}


- (NSString *)password{
    
    if (_password.length > 0) {
        return _password;
    }else{
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        _password = password;
        return _password;
    }
}

- (NSString *)getClientID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"client_id"];
}

- (NSString *)getClientSecret{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"client_secrete"];
}

- (NSString *)getAccessToken{
    //二级缓存
    if (self.access_token.length > 0) {
        return self.access_token;
    }else{
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        self.access_token = accessToken;
        return accessToken;
    }
}

- (NSString *)getRefreshToken{
    //二级缓存
    if (self.refresh_token.length > 0) {
        return self.refresh_token;
    }else{
        NSString *refresh_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"refresh_token"];
        self.refresh_token = refresh_token;
        return refresh_token;
    }
}

- (NSDate *)getExpiredDate{
    //二级缓存
    if (self.expiredDate) {
        return self.expiredDate;
    }else{
        NSDate *expiredDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"expired_date"];
        self.expiredDate = expiredDate;
        return expiredDate;
    }
}

- (NSArray *)getScopeArray{
    
    return self.scopesArr;

}



- (NSString *)authorizationStringWithStr1:(NSString *)str1 str2:(NSString *)str2 withPrefix:(NSString *)prefix
{
    NSData *encodeData = [[NSString stringWithFormat:@"%@:%@",str1,str2] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
    NSString *authorizationStr = [NSString stringWithFormat:@"%@ %@",prefix,base64String];
    return authorizationStr;
}

- (NSString *)generateRightsStringWidthScopesArr:(NSArray *)scopesArr{
    
    NSArray *arr = nil;
    
    if (scopesArr.count == 0) {
        
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Directions" ofType:@"json"]];
        NSDictionary *rightsDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        arr = [rightsDict objectForKey:@"data"];
    }else{
        arr = scopesArr;
    }
    
    NSMutableString * rightsStr = [NSMutableString string];
    for (NSString *right in arr) {
        NSString *rightWithBlack = [NSString stringWithFormat:@"%@ ",right];
        [rightsStr appendString:rightWithBlack];
    }
    return rightsStr;
    
}


- (NSString *)deviceName{
    
    NSString *device_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_name"];
    
    if (device_name.length > 0) {
        
        return device_name;
        
    }else{
        
        NSString *prefix=@"yunwang_ios_";
        NSString *uid =  [[NSUUID UUID] UUIDString];
        device_name = [prefix stringByAppendingString:uid];
        [[NSUserDefaults standardUserDefaults] setObject:device_name forKey:@"device_name"];
        return device_name;
    }
    
    
}



- (BOOL)hasCientIDAndClientSecrete{
    
    NSString *storedClientID = [self getClientID];;
    NSString *storedClientSecrete = [self getClientSecret];
    
    if (storedClientID.length > 0 && storedClientSecrete.length>0){
        return YES;
    }else{
        return NO;
    }
}



- (void)clearAllInfo{
    
    [self clearMemoryInfoCache];
    [self clearDiskInfoCache];
}


- (void)clearMemoryInfoCache{
    
    _user_id = nil;
    _password = nil;
    _access_token = nil;
    _refresh_token = nil;
    _expiredDate = nil;
    _token_type = nil;
    _scopesArr = nil;
    
}

- (void)clearDiskInfoCache {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"client_id"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"client_secrete"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refresh_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"expired_date"];
        
    });
    
}




@end
