//
//  WSOAPIClient.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/9/11.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSOAPIClient.h"
#import "AppDelegate.h"
#import "M_AuthenticationToken.h"
//#import "NSDictionary+DeepCopy.h"
#import "NSString+Extension.h"
//#import "JPUSHService.h"
#import <MBProgressHUD.h>
#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "BaseNavigationController.h"
static NSString * WSOJSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case -32700:
            return @"Parse Error";
        case -32600:
            return @"Invalid Request";
        case -32601:
            return @"Method Not Found";
        case -32602:
            return @"Invalid Params";
        case -32603:
            return @"Internal Error";
        default:
            return @"Server Error";
    }
}

@interface WSOAPIClient()

@property (nonatomic, strong) WSONetworkManager *networkManager;
@property (nonatomic, strong) WSONetworkConfig *networkConfig;
@property (nonatomic, strong) WSOTokenAgent *tokenAgent;
//认证token
@property(nonatomic,strong)M_AuthenticationToken *authenticationToken;
@end

@implementation WSOAPIClient

#pragma mark - Initialization

+ (WSOAPIClient *)sharedClient{
    
    static id sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.networkManager = [WSONetworkManager sharedManager];
        self.networkConfig  = [WSONetworkConfig sharedConfig];
        self.tokenAgent     = [WSOTokenAgent sharedAgent];
    }
    return self;
}

#pragma mark - Token Operations

//注册并获取token
- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password
                        tags:(NSArray *)tags
                      scopes:(NSArray *)scopes
                     success:(WSOSuccessBlock)success
                       error:(WSOErrorBlock)errorBlock
                     failure:(WSOFailureBlock)failure{
    
    if (self.ignoreToken) {
        WSOLog(@"忽略Token，不进行Token注册");
        return;
    }
    
    [self.tokenAgent fetchTokenWithUserName:userName
                                   passWord:password
                                       tags:tags
                                     scopes:scopes
                                    success:^(id response) {
                                        
                                        //检查scope
                                        NSString *errorMessage = nil;
                                        NSError *error = nil;
                                        NSArray *scopeArr = [self.tokenAgent getScopeArray];
                                        
                                        if ( (!scopeArr) || ([scopeArr count] == 1 && [scopeArr containsObject:@"default"])) {
                                            errorMessage = @"该用户没有权限";
                                            error = [NSError errorWithDomain:errorMessage code:WSOResponseErrorCodeWrongScope userInfo:nil];
                                            if (errorBlock) {
                                                WSOLog(@"########### 登录失败权限错误");
                                                errorBlock(error,errorMessage);
                                            }
                                            
                                        }else{
                                            
                                            WSOLog(@"########### 权限正确");
                                            //获取token之后，更新请求业务API的header
                                            [self changeTokenHeaderWithToken:[self.tokenAgent getAccessToken]];
                                            if (success) {
                                                success(response,200,@"");
                                            }
                                        }
                                        
                                    } failure:^(NSURLSessionDataTask *task,NSError *error) {
                                        
                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                        WSOLog(@" http response : %ld",(long)httpResponse.statusCode);
                                        if (error.code == 401) {
                                            NSString *errorMessage = error.domain;
                                            if (errorBlock) {
                                                WSOLog(@"########### 登录失败：用户名或密码错误");
                                                errorBlock(error,errorMessage);
                                                return;
                                            }
                                        }else if (httpResponse.statusCode == 403){
                                            NSString *errorMessage = @"此账号无此权限，请确认后输入";
                                            if (errorBlock) {
                                                WSOLog(@"########### 登录失败：该用户没有权限");
                                                errorBlock(error,errorMessage);
                                                return;
                                            }
                                        }else{
                                            
                                        }
                                        
                                        if (failure) {
                                            failure(error);
                                        }
                                    }];
}

- (void)getUserInfoSuccess:(WSOSuccessBlock)success
                     error:(WSOErrorBlock)errorBlock
                   failure:(WSOFailureBlock)failure{
    
    [[WSOTokenAgent sharedAgent] userInfoSuccess:^(id response) {
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
        if (error) {
            if (errorBlock) {
                error = [NSError errorWithDomain:@"获取用户信息失败：data转nsstring失败" code:WSOTokenFailueCodeFetchDataFormat userInfo:nil];
                TKLog(@"*********** 获取用户信息失败:%@",error);
                errorBlock(error,@"获取用户信息失败");
                return;
            }
        }else if ([[result allKeys] count] == 0){
            if (errorBlock) {
                error = [NSError errorWithDomain:@"获取用户信息失败：用户信息为空" code:WSOTokenFailueCodeFetchDataFormat userInfo:nil];
                TKLog(@"*********** 获取用户信息失败:%@",error);
                errorBlock(error,@"获取用户信息失败");
                return;
            }
        }else {
            if (success) {
                success(result,200,@"");
                TKLog(@"*********** 获取用户信息成功:%@",result);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//注销
- (void)unregisterSuccess:(WSOSuccessBlock)success
                    error:(WSOErrorBlock)errorBlock
                  failure:(WSOFailureBlock)failure{
    
    if (self.ignoreToken) {
        WSOLog(@"忽略Token，不进行Token注销");
        return;
    }
    [self.tokenAgent unregisterSuccess:^(id response) {
        
        if (success) {
            success(response,200,@"");
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error) {
        if (failure) {
            WSOLog(@"注销错误：%@",error);
            failure(error);
        }
    }];
    
}


//打印Token信息
- (void)logTokenInfo{
    
    if (self.ignoreToken) {
        return;
    }
    [self.tokenAgent logTokenInfo];
    
}

- (void)clearAllTokenInfo{
    
    [self.tokenAgent clearAllInfo];
}


- (void)changeTokenHeaderWithToken:(NSString *)accessToken{
    
    self.networkManager.tokenHeader = nil;
    NSDictionary *tokenHeader = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",[self.tokenAgent getAccessToken]]};
    self.networkManager.tokenHeader = tokenHeader;
}

#pragma mark - GET Requests

- (void)sendGetRequest:(NSString *)url
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodGET
           parameters:nil
            loadCache:NO
        cacheDuration:0
          ignoreToken:NO
              success:successBlock
                error:errorBlock
              failure:failureBlock];
}

- (void)sendGetRequest:(NSString *)url
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodGET
           parameters:nil
            loadCache:loadCache
        cacheDuration:cacheDuration
          ignoreToken:NO
     
              success:successBlock
                error:errorBlock
              failure:failureBlock];
    
}


- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodGET
           parameters:parameters
            loadCache:NO
        cacheDuration:0
          ignoreToken:NO
              success:successBlock
                error:errorBlock
              failure:failureBlock];
    
}

- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
           ignoreToken:(BOOL)ignoreToken
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodGET
           parameters:parameters
            loadCache:NO
        cacheDuration:0
          ignoreToken:ignoreToken
              success:successBlock
                error:errorBlock
              failure:failureBlock];
    
}

- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodGET
           parameters:parameters
            loadCache:loadCache
        cacheDuration:cacheDuration
          ignoreToken:NO
              success:successBlock
                error:errorBlock
              failure:failureBlock];
}

- (void)sendPutRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodPUT
           parameters:parameters
            loadCache:NO
        cacheDuration:0
          ignoreToken:NO
              success:successBlock
                error:errorBlock
              failure:failureBlock];
    
}
#pragma mark - POST Requests
- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock{
    [self sendRequest:url
               method:WSORequestMethodPOST
           parameters:parameters
            loadCache:NO
        cacheDuration:0
          ignoreToken:YES
              success:successBlock
                error:errorBlock
              failure:failureBlock];

}


- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
            ignoreToken:(BOOL)ignoreToken
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock{
    [self sendRequest:url
               method:WSORequestMethodPOST
           parameters:parameters
            loadCache:NO
        cacheDuration:0
          ignoreToken:ignoreToken
              success:successBlock
                error:errorBlock
              failure:failureBlock];
}

- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodPOST
           parameters:parameters
            loadCache:loadCache
        cacheDuration:cacheDuration
          ignoreToken:YES
              success:successBlock
                error:errorBlock
              failure:failureBlock];
    
}


- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
            ignoreToken:(BOOL)ignoreToken
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock{
    
    [self sendRequest:url
               method:WSORequestMethodPOST
           parameters:parameters
            loadCache:loadCache
        cacheDuration:cacheDuration
          ignoreToken:YES
              success:successBlock
                error:errorBlock
              failure:failureBlock];
}


//所有的请求都走的方法
- (void)sendRequest:(NSString *)url//统一处理返回的数据。用户退出登录时候的逻辑
             method:(WSORequestMethod)method
         parameters:(NSDictionary *)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
        ignoreToken:(BOOL)ignoreToken
            success:(WSOSuccessBlock)successBlock
              error:(WSOErrorBlock)errorBlock
            failure:(WSOFailureBlock)failureBlock{

        [self filteredTokenWithRequestUrl:url
                                   method:method
                               parameters:parameters
                                loadCache:loadCache
                              ignoreToken:ignoreToken
                            cacheDuration:cacheDuration
                                  success:successBlock
                                    error:errorBlock
                                  failure:failureBlock];


}


//token是否过期判断（刷新）之后，调用的最终发起网络请求的方法
- (void)filteredTokenWithRequestUrl:(NSString *)url
                             method:(WSORequestMethod)method
                         parameters:(id)parameters
                          loadCache:(BOOL)loadCache
                        ignoreToken:(BOOL)ignoreToken
                      cacheDuration:(NSTimeInterval)cacheDuration
                            success:(WSOSuccessBlock)successBlock
                              error:(WSOErrorBlock)errorBlock
                            failure:(WSOFailureBlock)failureBlock{
    
    
//    [self changeTokenHeaderWithToken:[self.tokenAgent getAccessToken]];
    NSDictionary *parametersDict = nil;
    //设置默认的请求参数  （默认参数包含。st 流水号 串号。 需要修改的参数摘要。 区分是否参数需要添加AT）
//    self.networkConfig.defailtParameters = @{@"app_version":[WSONetworkUtils appVersionStr]};
    parametersDict = parameters;
    __weak typeof (self) weakSelf = self;
    [self.networkManager sendRequest:url
                              method:method
                          parameters:parametersDict
                           loadCache:loadCache
                         ignoreToken:ignoreToken
                       cacheDuration:cacheDuration
                             success:^(id response) {
                                 //WSO2 规范的返回格式
                                 [self handleStandardWSOResponse:response success:successBlock error:errorBlock ignoreToken:ignoreToken];
                                 //成功的话 流水号要加 1

                                 //根据返回号如果
//                                 [weakSelf performSelector:@selector(ww_outLoginSuccess) withObject:weakSelf afterDelay:1];

                                 //1.ST有错（或过期） 重新认证。不登录
                                 //2.AT有错（或过期）重新登录 不认证
//                                 [self.authenticationToken authenticationWithAppType:@"" andDeviceIdentifier:@"" success:^(id response) {
//                                     
//                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//                                 }];
                             } failure:^(NSURLSessionDataTask *task,NSError *error) {
                                 
                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                 WSOLog(@" http response : %ld",(long)httpResponse.statusCode);
                                 if (httpResponse.statusCode == 401) {
                                     NSString *errorMessage = @"";
                                     if (errorBlock) {
                                         WSOLog(@"########### 网络请求失败：用户身份过期");                                                                               errorBlock(error,errorMessage);
                                         [weakSelf performSelector:@selector(ww_outLoginSuccess) withObject:weakSelf afterDelay:1];
                                         return;
                                     }
                                 }else {
                                        
                                     //网络错误，一律走failure
                                     if (failureBlock) {
                                         failureBlock(error);
                                     }

                                 }

                                 //网络错误，一律走failure
                                 if (failureBlock) {
                                     failureBlock(error);
                                 }
                             }];
}



#pragma mark - Upload Images


- (void)sendUploadImagesRequest:(NSString *)url
                     parameters:(id)parameters
                     imagesDict:(NSDictionary *)imageDict
                       progress:(WSOUploadProgressBlock)uploadProgressBlock
                        success:(WSOSuccessBlock)successBlock
                          error:(WSOErrorBlock)errorBlock
                        failure:(WSOFailureBlock)failureBlock{
    
    
    //判断token是否过期
    if ([self.tokenAgent isTokenExpired]) {
        
        //刷新token
        WSOLog(@"########### Token过期，重新刷新token");
        __weak typeof (self) weakSelf = self;
        [self.tokenAgent refreshTokenSuccess:^(id response){
            
            WSOLog(@"########### 重新刷新token成功");
            
            //检查scope
            NSString *errorMessage = nil;
            NSError *error = nil;
            
            if ( (![weakSelf.tokenAgent getScopeArray] ) || ([[weakSelf.tokenAgent getScopeArray]  count] == 1 && [[weakSelf.tokenAgent getScopeArray]  containsObject:@"default"])) {
                errorMessage = NSLocalizedString(@"登录信息已过期，请重新登录",@"");
                error = [NSError errorWithDomain:errorMessage code:WSOResponseErrorCodeWrongScope userInfo:nil];
                if (errorBlock) {
                    WSOLog(@"########### 刷新token后权限错误");
                    errorBlock(error,errorMessage);
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"7777777777777777777777"];
                    [weakSelf performSelector:@selector(ww_outLoginSuccess) withObject:weakSelf afterDelay:1];
                }
                
            }else{
                
                WSOLog(@"########### 刷新token后权限正确,立即请求接口");
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"4444444444444444444444"];
                [weakSelf filteredTokenWithUploadRequestUrl:url
                                                 parameters:parameters
                                                 imagesDict:imageDict
                                                   progress:uploadProgressBlock
                                                    success:successBlock
                                                      error:errorBlock
                                                    failure:failureBlock];
                
            }
            
            
            
            
        } failure:^(NSURLSessionDataTask *task,NSError *error) {
            
            WSOLog(@"########### 重新刷新token失败,准备重新登录");
            //重新登录
            [weakSelf.tokenAgent fetchTokenWithUserName:[self.tokenAgent getUserID]
                                               passWord:[self.tokenAgent password]
                                                   tags:@[@"device_management"]
                                                 scopes:[self.tokenAgent getScopeArray]
                                                success:^(id response) {
                                                    
                                                    
                                                    NSError *error = nil;
                                                    NSArray *scopeArr = [self.tokenAgent getScopeArray];
                                                    
                                                    if ( (!scopeArr) || ([scopeArr count] == 1 && [scopeArr containsObject:@"default"])) {
                                                        if (errorBlock) {
                                                            
                                                            WSOLog(@"########### 重新登录失败，权限错误，回到登录页面");
                                                            errorBlock(error,NSLocalizedString(@"登录信息已过期，请重新登录",@""));
                                                            
                                                            //                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"6666666666666666"];
                                                            [self performSelector:@selector(ww_outLoginSuccess) withObject:self afterDelay:1];
                                                            return;
                                                        }
                                                        
                                                    }else{
                                                        
                                                        WSOLog(@"########### 重新登录成功，再次请求接口");
                                                        //                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"8888888888888888"];
                                                        [weakSelf filteredTokenWithUploadRequestUrl:url
                                                                                         parameters:parameters
                                                                                         imagesDict:imageDict
                                                                                           progress:uploadProgressBlock
                                                                                            success:successBlock
                                                                                              error:errorBlock
                                                                                            failure:failureBlock];
                                                        
                                                    }
                                                    
                                                } failure:^(NSURLSessionDataTask *task,NSError *error) {
                                                    
                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                                    WSOLog(@" http response : %ld",(long)httpResponse.statusCode);
                                                    if (httpResponse.statusCode == 401) {
                                                        NSString *errorMessage = NSLocalizedString(@"登录信息已过期，请重新登录",@"");
                                                        if (errorBlock) {
                                                            WSOLog(@"########### 登录失败：用户名或密码错误");
                                                            //                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"******************"];
                                                            errorBlock(error,errorMessage);
                                                            [self performSelector:@selector(ww_outLoginSuccess) withObject:self afterDelay:1];
                                                            return;
                                                        }
                                                    }else if (httpResponse.statusCode == 403){
                                                        NSString *errorMessage = NSLocalizedString(@"登录信息已过期，请重新登录",@"");
                                                        if (errorBlock) {
                                                            WSOLog(@"########### 登录失败：该用户没有权限");
                                                            //                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"22222222222222"];
                                                            errorBlock(error,errorMessage);
                                                            [self performSelector:@selector(ww_outLoginSuccess) withObject:self afterDelay:1];
                                                            return;
                                                        }
                                                    }else{
                                                        
                                                    }
                                                    
                                                    //                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessage" object:@"33333333333333333"];
                                                    [weakSelf filteredTokenWithUploadRequestUrl:url
                                                                                 parameters:parameters
                                                                                 imagesDict:imageDict
                                                                                   progress:uploadProgressBlock
                                                                                    success:successBlock
                                                                                      error:errorBlock
                                                                                    failure:failureBlock];
                                                    
                                                }];
            
        }];
        
    }else{
        
        WSOLog(@"########### Token没有过期，直接请求");
        [self filteredTokenWithUploadRequestUrl:url
                                     parameters:parameters
                                     imagesDict:imageDict
                                       progress:uploadProgressBlock
                                        success:successBlock
                                          error:errorBlock
                                        failure:failureBlock];
        
    }
    
    
}



- (void)filteredTokenWithUploadRequestUrl:(NSString *)url
                               parameters:(id)parameters
                               imagesDict:(NSDictionary *)imageDict
                                 progress:(WSOUploadProgressBlock)uploadProgressBlock
                                  success:(WSOSuccessBlock)successBlock
                                    error:(WSOErrorBlock)errorBlock
                                  failure:(WSOFailureBlock)failureBlock{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    [imageDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSArray *items = [imageDict objectForKey:key];
        
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *itemDict = @{@"name":key,@"image":obj,@"ratio":@1,@"mimeType":@"jpg"};
            [array addObject:itemDict];
        }];
        
    }];
    
    [self changeTokenHeaderWithToken:[self.tokenAgent getAccessToken]];
    
    [self.networkManager sendUploadImagesRequest:url
                                   ignoreBaseUrl:NO
                                      parameters:parameters
                                      imageInfos:array
                                        progress:^(NSProgress *uploadProgress) {
                                            
                                            if (uploadProgressBlock) {
                                                uploadProgressBlock(uploadProgress);
                                            }
                                            
                                        } success:^(id response) {
                                            
                                            //WSO2 规范的返回格式
                                            [self handleStandardWSOResponse:response success:successBlock error:errorBlock ignoreToken:nil];
                                            
                                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            
                                            if (failureBlock) {
                                                failureBlock(error);
                                            }
                                            
                                        }];
    
}




- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSOUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(WSOSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(WSOFailureBlock _Nullable)uploadFailureBlock{
    
//    [self changeTokenHeaderWithToken:[self.tokenAgent getAccessToken]];
    
    [self.networkManager sendUploadImagesRequest:url
                                   ignoreBaseUrl:ignoreBaseUrl
                                      parameters:parameters
                                          images:images
                                   compressRatio:compressRatio
                                            name:name
                                        mimeType:mimeType
                                        progress:^(NSProgress *uploadProgress) {
                                            
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }
                                            
    } success:^(id response) {
        
        if (uploadSuccessBlock) {
            uploadSuccessBlock(response,200,@"");
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        if (uploadFailureBlock) {
            uploadFailureBlock(error);
        }
    }];
}

//上传图片接口3
- (void)sendUploadImageRequest:(NSString *)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id)parameters
                         images:(UIImage*)image
                  compressRatio:(float)compressRatio
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(WSOUploadProgressBlock)uploadProgressBlock
                        success:(WSOSuccessBlock)uploadSuccessBlock
                        failure:(WSOFailureBlock)uploadFailureBlock
{
    
    [self.networkManager sendUploadImageRequest:url ignoreBaseUrl:ignoreBaseUrl parameters:parameters images:image compressRatio:compressRatio name:name mimeType:mimeType progress:^(NSProgress *uploadProgress) {
        
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }

    } success:^(id response) {
        if (uploadSuccessBlock) {
            uploadSuccessBlock(response,200,@"");
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        

        if (uploadFailureBlock) {
            uploadFailureBlock(error);
        }
    }];
    
}

//上传文件接口
- (void)sendUploadFileRequest:(NSString *)url
                ignoreBaseUrl:(BOOL)ignoreBaseUrl
                   parameters:(id)parameters
                       fileData:(NSData*)fileData
                         name:(NSString *)name
                     mimeType:(NSString *)mimeType
                     progress:(WSOUploadProgressBlock)uploadProgressBlock
                      success:(WSOSuccessBlock)uploadSuccessBlock
                      failure:(WSOFailureBlock)uploadFailureBlock
{

    
    [self.networkManager sendUploadFileRequest:url ignoreBaseUrl:ignoreBaseUrl parameters:parameters fileData:fileData name:name mimeType:@"" progress:^(NSProgress *uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }
    } success:^(id response) {
        if (uploadSuccessBlock) {
            uploadSuccessBlock(response,200,@"");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        if (uploadFailureBlock) {
            uploadFailureBlock(error);
        }
    }];
    
}

#pragma mark - Requests Operation
//取消当前所有请求
- (void)cancelAllCurrentRequests{
    
    [self.networkManager cancelAllCurrentRequests];
}

//取消带有某个url的请求
- (void)cancelCurrentRequestWithUrl:(NSString *)url{
    
    [self.networkManager cancelCurrentRequestWithUrl:url];
}

//取消所有缓存
- (void)clearAllCache{
    [self.networkManager clearAllCacheWithCompletionBlock:nil];
}

//取消带有某个url的请求
- (void)clearCacheWithUrl:(NSString *)url{
    [self.networkManager clearCacheWithUrl:url completionBlock:nil];
    
}

//打印所有当前的请求
- (void)logAllCurrentRequests{
    [self.networkManager logAllCurrentRequests];
}



#pragma mark- Private Methods

- (void)handleStandardWSOResponse:(id)response success:(WSOSuccessBlock)successBlock error:(WSOErrorBlock)errorBlock ignoreToken:(BOOL)ignoreToken{
//        //流水号加1
//        NSString *serialNum = [[UserPreferenceManager defaultManager] getUserSerialNum];
//        NSInteger serN = [serialNum integerValue];
//        serN ++;
//        [[UserPreferenceManager defaultManager] saveUserSerialNum:[NSString stringWithFormat:@"%ld",(long)serN]];
    if (!response) {
        if (errorBlock) {
            NSError *error = [NSError errorWithDomain:@"没有返回数据" code:WSOResponseErrorCodeNOResponse userInfo:nil];
            WSOLog(@"########### 没有返回数据%@",error);
            errorBlock(error,error.domain);
            return;
        }
    }
    
    //最先检查返回数据是不是字典
    if (![response isKindOfClass:[NSDictionary class]]) {
        if (errorBlock) {
            NSError *error = [NSError errorWithDomain:@"返回数据格式错误" code:WSOResponseErrorCodeFormatError userInfo:nil];
            WSOLog(@"########### 数据格式错误%@",error);
            errorBlock(error,error.domain);
            return;
        }
    }
    
    //返回数据是字典
    NSDictionary *responseDict = response;

    //获取message
    NSString *message;
    id messageObj = [responseDict objectForKey:@"statusMsg"];
    if (!messageObj || (![messageObj isKindOfClass:[NSString class]]) ) {
        message = @"";
    }else{
        message = messageObj;
    }
    
    //获取code
    id codeObj = [responseDict objectForKey:@"statusCode"];
    
    NSUInteger code;

    code = [codeObj integerValue];

    
    switch (code) {
        case 1005:
            break;
        case 1006:
            //重新认证
            [self recertificationAgain];
            break;
        case 1007:
            //重新认证service_token
            [self recertificationAgain];
            break;
        case 1008:
            //重新认证
            [self recertificationAgain];
            break;
        case 1009:
            //重新登录。切换到登录页面(AT不存在)
            [self performSelector:@selector(tokenExporedoutLogin) withObject:self afterDelay:1];
            break;
        case 1010:
            //重新认证
            [self recertificationAgain];
            break;

        case 1012:
            //重新登录。切换到登录页面(AT不存在)
            [self performSelector:@selector(tokenExporedoutLogin) withObject:self afterDelay:1];
            break;
        case 1013:
            //重新登录。切换到登录页面(AT不存在)
            [self performSelector:@selector(ww_outLoginSuccess) withObject:self afterDelay:1];
            break;
        case 1016://statusCode 1016 手机时间和服务器时间不一致,请联系管理员
            [self showTipWithMessage:@"手机时间和服务器时间不一致,请联系管理员"];
            break;
        case 1401:
            [self showTipWithMessage:@""];
            break;
        case -1:
            [self showTipWithMessage:@""];
            break;
        default:
            break;
    }
    id data = [responseDict objectForKey:@"data"];
    if (!data) {
        if (errorBlock) {
            NSError *error = [NSError errorWithDomain:@"返回数据不存在" code:WSOResponseErrorCodeDataEmpty userInfo:nil];
            WSOLog(@"########### data不存在%@",error);
            errorBlock(error,message);
        }
    }
    
    if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]]) {
        //字典或者数组，正确
        if (successBlock) {
            successBlock(data,code,message);
        }
            
    }else{
        //不是字典或者数组，错误
        if (errorBlock) {
            NSError *error = [NSError errorWithDomain:@"返回数据格式错误" code:WSOResponseErrorCodeFormatError userInfo:nil];
            WSOLog(@"########### 返回数据格式错误:%@",error);
            errorBlock(error,message);
        }
    }
}

- (void)recertificationAgain{
//    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
//    [[M_AuthenticationToken sharedAuthentication] authenticationWithAppType:@"2" andDeviceIdentifier:identifierForVendor success:^(id response) {
//        NSDictionary *responseObj = response;
//        //保存盐
//        NSString *salt = [NSString stringWithFormat:@"%@",responseObj[@"data"][@"salt"]];
//        [[UserPreferenceManager defaultManager] saveSaltString:salt];
//        //保存ST
//        NSString *st = [NSString stringWithFormat:@"%@",responseObj[@"data"][@"st"]];
//        [[UserPreferenceManager defaultManager] saveUserStString:st];
//        [self showTipWithMessage:@""];
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//    }];

}

//设置base url：网络框架和token同时设置
- (void)setBaseUrl:(NSString *)baseUrl{

    self.networkConfig.baseUrl = baseUrl;
    self.tokenAgent.baseUrl = baseUrl;
}

//设置默认参数
- (void)setDefaultParameters:(NSDictionary *)defaultParameters
{
    self.networkConfig.defailtParameters = defaultParameters;
}

- (void)tokenExporedoutLogin{
    UIViewController *vc = nil;
    if ([FDWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)FDWindow.rootViewController).viewControllers.lastObject;
    }else{
        vc = FDWindow.rootViewController;
    }
    NSString *promot = @"Prompt";
    UIAlertController *Alert = [UIAlertController alertControllerWithTitle:promot message:@"LoginExpired" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //判断如果是在登录页面，那么不进行跳转
        if ([vc isKindOfClass:[LoginViewController class]]) {
            return;
        }

        LoginViewController *loginVC = [[LoginViewController alloc] init];
        BaseNavigationController *navL = [[BaseNavigationController alloc]initWithRootViewController:loginVC];
        //iOS 自定义view里实现控制器的跳转
        UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;

        UINavigationController *nav = (UINavigationController *)tabBarVc.selectedViewController;
        nav.hidesBottomBarWhenPushed = YES;
//        [nav pushViewController:loginVC animated:YES];
        [nav presentViewController:navL animated:YES completion:nil];
        nav.hidesBottomBarWhenPushed = YES;
    }];
    [Alert addAction:sureAction];
    [vc presentViewController:Alert animated:YES completion:nil];
}

- (void)ww_outLoginSuccess{
        UIViewController *vc = nil;
        if ([FDWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)FDWindow.rootViewController).viewControllers.lastObject;
        }else{
            vc = FDWindow.rootViewController;
        }
    NSString *promot = @"Prompt";
    UIAlertController *Alert = [UIAlertController alertControllerWithTitle:promot message:@"letout" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //判断如果是在登录页面，那么不进行跳转
        if ([vc isKindOfClass:[LoginViewController class]]) {
            return;
        }
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        BaseNavigationController *navL = [[BaseNavigationController alloc]initWithRootViewController:loginVC];
        //iOS 自定义view里实现控制器的跳转
        UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav = (UINavigationController *)tabBarVc.selectedViewController;
        nav.hidesBottomBarWhenPushed = YES;
        [nav presentViewController:navL animated:YES completion:nil];
        nav.hidesBottomBarWhenPushed = YES;
    }];
    [Alert addAction:sureAction];
    [vc presentViewController:Alert animated:YES completion:nil];

    
}

-(void)showTipWithMessage:(NSString *)aMessage{
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    tip.mode = MBProgressHUDModeText;
    tip.margin = 10.f;
    //    tip.yOffset = 150.f;
//    tip.labelText = aMessage;
    tip.detailsLabelText= aMessage;
    tip.detailsLabelFont = [UIFont boldSystemFontOfSize:12.0];
    tip.labelFont = [UIFont systemFontOfSize:12.0];
    [tip show:YES];
    [tip hide:YES afterDelay:1.5];
}

@end

