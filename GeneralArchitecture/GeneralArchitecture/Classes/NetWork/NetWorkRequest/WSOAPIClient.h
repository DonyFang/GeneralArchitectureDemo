//
//  WSOAPIClient.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/9/11.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSOTokenAgent.h"
#import "WSONetworking.h"

typedef void(^WSOSuccessBlock)(id response, NSUInteger code, NSString *message);  //返回正确的数据格式
typedef void(^WSOUploadProgressBlock)(NSProgress *uploadProgress);  //上传进度
typedef void(^WSOErrorBlock)(NSError *error,NSString *message);     //业务型错误
typedef void(^WSOFailureBlock)(NSError *error);                     //网络型错误

typedef enum : NSUInteger {
    WSOResponseErrorCodeNOResponse  = -6000,
    WSOResponseErrorCodeFormatError = -6001,
    WSOResponseErrorCodeDataEmpty   = -6002,
    WSOResponseErrorCodeWrongScope  = -6003,
} WSOResponseErrorCode;

@interface WSOAPIClient : NSObject

@property (nonatomic, copy) NSString *baseUrl;  
@property (nonatomic, assign) BOOL ignoreToken; //是否忽略token，默认是NO。如果是YES，则不走Token的判断

//单例
+ (WSOAPIClient *)sharedClient;

// ======================== Token ======================== //

/**
 *  注册并获取token
 *
 *  @param userName      用户名
 *  @param password      密码
 *  @param tags          tag，默认为device_management
 *  @param scopes        权限
 *  @param success       请求成功回调
 *  @param failure       请求失败回调
 *
 */
- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password
                        tags:(NSArray *)tags
                      scopes:(NSArray *)scopes
                     success:(WSOSuccessBlock)success
                       error:(WSOErrorBlock)errorBlock
                     failure:(WSOFailureBlock)failure;



/**
 *  获取用户信息
 *  @param success       请求成功回调
 *  @param failure       请求失败回调
 *
 */
- (void)getUserInfoSuccess:(WSOSuccessBlock)success
                     error:(WSOErrorBlock)errorBlock
                   failure:(WSOFailureBlock)failure;

/**
 *  注销
 *
 *  @param success       请求成功回调
 *  @param failure       请求失败回调
 *
 */
- (void)unregisterSuccess:(WSOSuccessBlock)success
                    error:(WSOErrorBlock)errorBlock
                  failure:(WSOFailureBlock)failure;


/**
 *  打印Token的所有相关信息
 */
- (void)logTokenInfo;


/**
 *  清除Token的所有相关信息
 */
- (void)clearAllTokenInfo;


// ======================= Request ======================= //


/**
 *  POST请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock;


/**
 *  PUT请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendPutRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock;

/**
 *  POST请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param ignoreToken        是否忽略token
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
            ignoreToken:(BOOL)ignoreToken
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock;



/**
 *  POST请求，考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param loadCache          是否获取缓存
 *  @param cacheDuration      缓存保存时间
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock;


/**
 *  POST请求，考虑缓存，可忽略token
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param loadCache          是否获取缓存
 *  @param cacheDuration      缓存保存时间
 *  @param ignoreToken        是否忽略token
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendPostRequest:(NSString *)url
             parameters:(NSDictionary *)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
            ignoreToken:(BOOL)ignoreToken
                success:(WSOSuccessBlock)successBlock
                  error:(WSOErrorBlock)errorBlock
                failure:(WSOFailureBlock)failureBlock;




/**
 *  GET请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendGetRequest:(NSString *)url
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock;

/**
 *  GET请求，考虑缓存
 *
 *  @param url                请求url
 *  @param loadCache          是否获取缓存
 *  @param cacheDuration      缓存保存时间
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendGetRequest:(NSString *)url
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock;

/**
 *  GET请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock;


/**
 *  GET请求，不考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
           ignoreToken:(BOOL)ignoreToken
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock;

/**
 *  GET请求，考虑缓存
 *
 *  @param url                请求url
 *  @param parameters         请求参数
 *  @param loadCache          是否获取缓存
 *  @param cacheDuration      缓存保存时间
 *  @param successBlock       请求成功回调
 *  @param errorBlock         请求错误回调
 *  @param failureBlock       请求失败回调
 *
 */
- (void)sendGetRequest:(NSString *)url
            parameters:(NSDictionary *)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSOSuccessBlock)successBlock
                 error:(WSOErrorBlock)errorBlock
               failure:(WSOFailureBlock)failureBlock;



//上传图片接口1
- (void)sendUploadImagesRequest:(NSString *)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id)parameters
                         images:(NSArray<UIImage *> *)images
                  compressRatio:(float)compressRatio
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(WSOUploadProgressBlock)uploadProgressBlock
                        success:(WSOSuccessBlock)uploadSuccessBlock
                        failure:(WSOFailureBlock)uploadFailureBlock;



//上传图片接口2
- (void)sendUploadImagesRequest:(NSString *)url
                     parameters:(id)parameters
                     imagesDict:(NSDictionary *)imageDict
                       progress:(WSOUploadProgressBlock)uploadProgressBlock
                        success:(WSOSuccessBlock)successBlock
                          error:(WSOErrorBlock)errorBlock
                        failure:(WSOFailureBlock)failureBlock;



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
                        failure:(WSOFailureBlock)uploadFailureBlock;

//上传文件接口
- (void)sendUploadFileRequest:(NSString *)url
                ignoreBaseUrl:(BOOL)ignoreBaseUrl
                   parameters:(id)parameters
                     fileData:(NSData*)fileData
                         name:(NSString *)name
                     mimeType:(NSString *)mimeType
                     progress:(WSOUploadProgressBlock)uploadProgressBlock
                      success:(WSOSuccessBlock)uploadSuccessBlock
                      failure:(WSOFailureBlock)uploadFailureBlock;


/**
 *  取消当前所有请求
 */
- (void)cancelAllCurrentRequests;


/**
 *  取消带有某个url的请求
 *
 *  @param url                请求url
 *
 */
- (void)cancelCurrentRequestWithUrl:(NSString *)url;


/**
 *  清除所有缓存
 */
- (void)clearAllCache;


/**
 *  取消带有某个url的请求
 *
 *  @param url                请求url
 *
 */
- (void)clearCacheWithUrl:(NSString *)url;


/**
 *  打印所有当前的请求
 */
- (void)logAllCurrentRequests;



@end
