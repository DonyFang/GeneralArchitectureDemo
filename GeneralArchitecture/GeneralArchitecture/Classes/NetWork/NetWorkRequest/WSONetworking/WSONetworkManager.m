//
//  WSONetworkManager.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSONetworkManager.h"
#import "WSONetworkCacheManager.h"
#import "WSONetworkConfig.h"
#import "WSONetworkUtils.h"
#import "CompressPicturesTool.h"
#import "UserPreferenceManager.h"
#import "NSString+TimeStamp.h"
//#import "NSDictionary+DeepCopy.h"
#import <CommonCrypto/CommonDigest.h>
#import <pthread/pthread.h>
#import "objc/runtime.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif


#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

/**
 *  A dictionary which holds the current requests. Key is the identifer of task,value is request model
 */
typedef NSMutableDictionary<NSString *, WSONetworkRequestModel *> WSOCurrentRequestModels;

/**
 *  A key that help WSONetworkManager instance to hold the dictionary
 */
static char currentRequestModelsKey;

@interface WSONetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *uploadSessionManager;

@end


@implementation WSONetworkManager
{
    dispatch_queue_t _processingQueue;
    pthread_mutex_t _lock;
}


#pragma mark- Life Cycle

+ (WSONetworkManager *)sharedManager {
    
    static WSONetworkManager *sharedManager = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
         sharedManager = [[WSONetworkManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self createSessionManager];
        [self createUploadSessionManager];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)createSessionManager{
    
    //AFSessionManager config
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.requestSerializer.allowsCellularAccess = YES;
//    _sessionManager.requestSerializer.timeoutInterval = 50;
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //此处是支持http请求
//    _sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    //     _sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];  适配https请求
    [_sessionManager.securityPolicy setValidatesDomainName:NO];
//        _sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    [_sessionManager.securityPolicy setValidatesDomainName:NO];
    [_sessionManager.securityPolicy setAllowInvalidCertificates:YES];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    // 设置超时时间(设置有效)
    [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _sessionManager.requestSerializer.timeoutInterval = 50;
    [_sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
    
}

- (void)createUploadSessionManager{
    
    //AFSessionManager config
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _uploadSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    _uploadSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _uploadSessionManager.requestSerializer.allowsCellularAccess = YES;
    _uploadSessionManager.requestSerializer.timeoutInterval = 50;
//    [_uploadSessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_uploadSessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
//    _uploadSessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    [_uploadSessionManager.securityPolicy setAllowInvalidCertificates:YES];
    _uploadSessionManager.securityPolicy.validatesDomainName = NO;
//    是否允许无效证书
//    _uploadSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _uploadSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _uploadSessionManager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    
    _uploadSessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _uploadSessionManager.operationQueue.maxConcurrentOperationCount = 5;
    
}

- (void)dealloc{
    [self cancelAllCurrentRequests];
}

#pragma mark- Request API

#pragma mark Request API using GET method

- (void)sendGetRequest:(NSString *)url
            parameters:(id)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSO2SuccessBlock)successBlock
               failure:(WSO2FailureBlock)failureBlock{
    
     [self sendRequest:url
                method:WSORequestMethodGET
            parameters:parameters
             loadCache:loadCache
           ignoreToken:nil
         cacheDuration:cacheDuration
               success:successBlock
              failure:failureBlock];
    
}


- (void)sendGetRequest:(NSString *)url
            parameters:(id)parameters
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSO2SuccessBlock)successBlock
               failure:(WSO2FailureBlock)failureBlock{
    
     [self sendRequest:url
                method:WSORequestMethodGET
            parameters:parameters
             loadCache:NO
           ignoreToken:nil
         cacheDuration:cacheDuration
               success:successBlock
               failure:failureBlock];
    
}


- (void)sendGetRequest:(NSString *)url
            parameters:(id)parameters
             loadCache:(BOOL)loadCache
               success:(WSO2SuccessBlock)successBlock
               failure:(WSO2FailureBlock)failureBlock{
    
     [self sendRequest:url
                method:WSORequestMethodGET
            parameters:parameters
             loadCache:loadCache
           ignoreToken:nil
         cacheDuration:0
               success:successBlock
               failure:failureBlock];
    
}



- (void)sendGetRequest:(NSString *)url
            parameters:(id)parameters
               success:(WSO2SuccessBlock)successBlock
               failure:(WSO2FailureBlock)failureBlock{
    
     [self sendRequest:url
                method:WSORequestMethodGET
            parameters:parameters
             loadCache:NO
           ignoreToken:nil
         cacheDuration:0
               success:successBlock
               failure:failureBlock];
}




#pragma mark Request API using POST method

- (void)sendPostRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSO2SuccessBlock)successBlock
                failure:(WSO2FailureBlock)failureBlock{
    
      [self sendRequest:url
                 method:WSORequestMethodPOST
             parameters:parameters
              loadCache:loadCache
            ignoreToken:nil
          cacheDuration:cacheDuration
                success:successBlock
                failure:failureBlock];
    
}


- (void)sendPostRequest:(NSString *)url
             parameters:(id)parameters
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSO2SuccessBlock)successBlock
                failure:(WSO2FailureBlock)failureBlock{
    
      [self sendRequest:url
                 method:WSORequestMethodPOST
             parameters:parameters
              loadCache:NO
            ignoreToken:nil
          cacheDuration:cacheDuration
                success:successBlock
                failure:failureBlock];
}


- (void)sendPostRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
                success:(WSO2SuccessBlock)successBlock
                failure:(WSO2FailureBlock)failureBlock{
    
      [self sendRequest:url
                 method:WSORequestMethodPOST
             parameters:parameters
              loadCache:loadCache
            ignoreToken:nil
          cacheDuration:0
                success:successBlock
                failure:failureBlock];
}



- (void)sendPostRequest:(NSString *)url
             parameters:(id)parameters
                success:(WSO2SuccessBlock)successBlock
                failure:(WSO2FailureBlock)failureBlock{
    
      [self sendRequest:url
                 method:WSORequestMethodPOST
             parameters:parameters
              loadCache:NO
            ignoreToken:nil
          cacheDuration:0
                success:successBlock
                failure:failureBlock];
}




#pragma mark Request API using specific parameters

- (void)sendRequest:(NSString *)url
         parameters:(id)parameters
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
    if (parameters) {
        
        [self sendRequest:url
                   method:WSORequestMethodPOST
               parameters:parameters
                loadCache:NO
              ignoreToken:nil
            cacheDuration:0
                  success:successBlock
                  failure:failureBlock];
        
    }else{
        
        [self sendRequest:url
                   method:WSORequestMethodGET
               parameters:nil
                loadCache:NO
              ignoreToken:nil
            cacheDuration:0
                  success:successBlock
                  failure:failureBlock];
    
    }
}

- (void)sendRequest:(NSString *)url
         parameters:(id)parameters
          loadCache:(BOOL)loadCache
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
  
    
    if (parameters) {
        
        [self sendRequest:url
                   method:WSORequestMethodPOST
               parameters:parameters
                loadCache:loadCache
              ignoreToken:nil
            cacheDuration:0
                  success:successBlock
                  failure:failureBlock];
        
    }else{
        
        [self sendRequest:url
                   method:WSORequestMethodGET
               parameters:nil
                loadCache:loadCache
              ignoreToken:nil
            cacheDuration:0
                  success:successBlock
                  failure:failureBlock];
        
    }
    
}

- (void)sendRequest:(NSString *)url
         parameters:(id)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
    
    
    if (parameters) {
        
        [self sendRequest:url
                   method:WSORequestMethodPOST
               parameters:parameters
                loadCache:NO
              ignoreToken:nil
            cacheDuration:cacheDuration
                  success:successBlock
                  failure:failureBlock];
        
    }else{
        
        [self sendRequest:url
                   method:WSORequestMethodGET
               parameters:nil
                loadCache:NO
              ignoreToken:nil
            cacheDuration:cacheDuration
                  success:successBlock
                  failure:failureBlock];
        
    }
   
    
}

- (void)sendRequest:(NSString *)url
         parameters:(id)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
    
    if (parameters) {
        
        [self sendRequest:url
                   method:WSORequestMethodPOST
               parameters:parameters
                loadCache:loadCache
              ignoreToken:nil
            cacheDuration:cacheDuration
                  success:successBlock
                  failure:failureBlock];
        
    }else{
        
        [self sendRequest:url
                   method:WSORequestMethodGET
               parameters:nil
                loadCache:loadCache
              ignoreToken:nil
            cacheDuration:cacheDuration
                  success:successBlock
                  failure:failureBlock];
        
    }
}


- (void)sendUploadImagesRequest:(NSString *)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id)parameters
                     imageInfos:(NSArray *)imageInfos
                       progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                        success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                        failure:(WSO2FailureBlock _Nullable)uploadFailureBlock{
    
    //default method is POST
    NSString *methodStr = @"POST";
    
    //generate full request url
    NSString *completeUrlStr = nil;
    
    //generate a unique identifer of a spectific request
    NSString *requestIdentifer = nil;
    
    if (ignoreBaseUrl) {
        
        completeUrlStr   = url;
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:nil
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }else{
        
        completeUrlStr   = [[WSONetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }
    
    //add custom headers
    //Add Headers
        if (self.tokenHeader && [self.tokenHeader allKeys] > 0) {
            NSArray *allKeys = [self.tokenHeader allKeys];
            for (NSInteger index = 0; index < allKeys.count; index++) {
                NSString *key = allKeys[index];
                NSString *value = [self.tokenHeader objectForKey:key];
                WSOLog(@"=========== add header:key:%@ value:%@",key,value);
                [_uploadSessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
    
        }
    
    //add default parameters
    //if there is default parameters, add them into request body(POST request only)
    id parameters_spliced = nil;
    if ([methodStr isEqualToString:@"POST"] && [parameters isKindOfClass:[NSDictionary class]] && ([WSONetworkConfig sharedConfig].defailtParameters)) {
        
        NSMutableDictionary *defaultParameters_m = [[WSONetworkConfig sharedConfig].defailtParameters mutableCopy];
        [defaultParameters_m addEntriesFromDictionary:parameters];
        parameters_spliced = [defaultParameters_m copy];
        
    }else{
        parameters_spliced = parameters;
    }
    
    
    //create corresponding request model and send request with it
    WSONetworkRequestModel *requestModel = [[WSONetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = parameters;
    requestModel.uploadImageInfos = imageInfos;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = uploadSuccessBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    requestModel.failureBlock= uploadFailureBlock;
    
    [self p_sendUploadImagesWithImageInfoRequestWithRequestModel:requestModel];
}


#pragma mark- Upload Image

- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                        success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                        failure:(WSO2FailureBlock _Nullable)uploadFailureBlock{
    
//    if images count equals 0, then return
    if ([images count] == 0) {
        WSOLog(@"=========== Upload image failed:There is no image to upload!");
        return;
    }

    
    //default method is POST
    NSString *methodStr = @"POST";
    
    //generate full request url
    NSString *completeUrlStr = nil;
    
    //generate a unique identifer of a spectific request
    NSString *requestIdentifer = nil;
    
    if (ignoreBaseUrl) {
        
        completeUrlStr   = url;
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:nil
                                                                    requestUrlStr:url
                                                                        method:methodStr
                                                                       parameters:parameters];
    }else{
        
        completeUrlStr   = [[WSONetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                    requestUrlStr:url
                                                                        method:methodStr
                                                                       parameters:parameters];
    }
    
    //add custom headers
    //Add Headers
//    if (self.tokenHeader && [self.tokenHeader allKeys] > 0) {
//        NSArray *allKeys = [self.tokenHeader allKeys];
//        for (NSInteger index = 0; index < allKeys.count; index++) {
//            NSString *key = allKeys[index];
//            NSString *value = [self.tokenHeader objectForKey:key];
//            WSOLog(@"=========== add header:key:%@ value:%@",key,value);
//            [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
//        }
//
//    }
    
    //add default parameters
    //if there is default parameters, add them into request body(POST request only)
    id parameters_spliced = nil;
    if ([methodStr isEqualToString:@"POST"] && [parameters isKindOfClass:[NSDictionary class]] && ([WSONetworkConfig sharedConfig].defailtParameters)) {
        
        NSMutableDictionary *defaultParameters_m = [[WSONetworkConfig sharedConfig].defailtParameters mutableCopy];
        [defaultParameters_m addEntriesFromDictionary:parameters];
        parameters_spliced = [defaultParameters_m copy];
        
    }else{
        parameters_spliced = parameters;
    }
    
    
    //create corresponding request model and send request with it
    WSONetworkRequestModel *requestModel = [[WSONetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = parameters_spliced;
    requestModel.uploadImages = images;
    requestModel.imageCompressRatio = compressRatio;
    requestModel.imagesIdentifer = name;
    requestModel.mimeType = mimeType;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = uploadSuccessBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    requestModel.failureBlock= uploadFailureBlock;
    
    [self p_sendUploadImagesRequestWithRequestModel:requestModel];
}

- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(UIImage* _Nonnull)image
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                        success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                        failure:(WSO2FailureBlock _Nullable)uploadFailureBlock{


    //default method is POST
    NSString *methodStr = @"POST";

    //generate full request url
    NSString *completeUrlStr = nil;

    //generate a unique identifer of a spectific request
    NSString *requestIdentifer = nil;

    if (ignoreBaseUrl) {

        completeUrlStr   = url;
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:nil
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }else{

        completeUrlStr   = [[WSONetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }


    //add default parameters
    //if there is default parameters, add them into request body(POST request only)
    id parameters_spliced = nil;
    if ([methodStr isEqualToString:@"POST"] && [parameters isKindOfClass:[NSDictionary class]] && ([WSONetworkConfig sharedConfig].defailtParameters)) {

        NSMutableDictionary *defaultParameters_m = [[WSONetworkConfig sharedConfig].defailtParameters mutableCopy];
        [defaultParameters_m addEntriesFromDictionary:parameters];
        parameters_spliced = [defaultParameters_m copy];

    }else{
        parameters_spliced = parameters;
    }

    
    //create corresponding request model and send request with it
    WSONetworkRequestModel *requestModel = [[WSONetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = parameters_spliced;
    requestModel.imageCompressRatio = compressRatio;
    requestModel.imagesIdentifer = name;
    requestModel.uploadImage = image;
    requestModel.uploadImageName = name;
    requestModel.mimeType = mimeType;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = uploadSuccessBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    requestModel.failureBlock= uploadFailureBlock;
    [self m_sendUploadImageRequestWithRequestModel:requestModel];
}


- (void)sendUploadFileRequest:(NSString * _Nonnull)url
                ignoreBaseUrl:(BOOL)ignoreBaseUrl
                   parameters:(id _Nullable)parameters
                     fileData:(NSData * _Nonnull)fileData
                         name:(NSString * _Nonnull)name
                     mimeType:(NSString * _Nullable)mimeType
                     progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                      success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                      failure:(WSO2FailureBlock _Nullable)uploadFailureBlock
{


    //default method is POST
    NSString *methodStr = @"POST";

    //generate full request url
    NSString *completeUrlStr = nil;

    //generate a unique identifer of a spectific request
    NSString *requestIdentifer = nil;

    if (ignoreBaseUrl) {

        completeUrlStr   = url;
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:nil
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }else{

        completeUrlStr   = [[WSONetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                     requestUrlStr:url
                                                                            method:methodStr
                                                                        parameters:parameters];
    }


    //add default parameters
    //if there is default parameters, add them into request body(POST request only)
    id parameters_spliced = nil;
    if ([methodStr isEqualToString:@"POST"] && [parameters isKindOfClass:[NSDictionary class]] && ([WSONetworkConfig sharedConfig].defailtParameters)) {

        NSMutableDictionary *defaultParameters_m = [[WSONetworkConfig sharedConfig].defailtParameters mutableCopy];
        [defaultParameters_m addEntriesFromDictionary:parameters];
        parameters_spliced = [defaultParameters_m copy];

    }else{
        parameters_spliced = parameters;
    }


    //create corresponding request model and send request with it
    WSONetworkRequestModel *requestModel = [[WSONetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = parameters_spliced;
    requestModel.mimeType = mimeType;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = uploadSuccessBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    requestModel.failureBlock= uploadFailureBlock;
    requestModel.fileName = name;
    requestModel.fileData = fileData;
    [self m_sendUploadFileRequestWithRequestModel:requestModel];
    
}


- (void)m_sendUploadFileRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{

__weak __typeof(self) weakSelf = self;
NSURLSessionDataTask *uploadTask = [_uploadSessionManager           POST:requestModel.requestUrl
                  parameters:requestModel.parameters
   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       //image data
       NSData *fileData = requestModel.fileData;
       [formData appendPartWithFileData:fileData
                                   name:@"aFile"
                               fileName:requestModel.fileName
                               mimeType:@"aFile/text"];
   } progress:^(NSProgress * _Nonnull uploadProgress) {
       WSOLog(@"=========== Upload File progress:%@",uploadProgress);
       dispatch_async(dispatch_get_main_queue(), ^{
           if (requestModel.uploadProgressBlock) {
               requestModel.uploadProgressBlock(uploadProgress);
           }    
       });

   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       WSOLog(@"=========== Upload File request succeed:%@\n =========== Successfully uploaded File:%@",responseObject,requestModel.uploadImages);
       dispatch_async(dispatch_get_main_queue(), ^{
           if (requestModel.successBlock) {
               requestModel.successBlock(responseObject);
           }
           [weakSelf handleRequestModelFinished:requestModel];
       });
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       WSOLog(@"=========== Upload File request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed File:%@:",error,(long)error.code,requestModel.uploadImages);
       dispatch_async(dispatch_get_main_queue(), ^{

           if (requestModel.failureBlock) {
               requestModel.failureBlock(task, error);
           }

           [weakSelf handleRequestModelFinished:requestModel];

       });

   }];

requestModel.dataTask = uploadTask;
[self addRequestModel:requestModel];

}



- (void)m_sendUploadImageRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{

    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *uploadTask = [_uploadSessionManager           POST:requestModel.requestUrl
                    parameters:requestModel.parameters
     constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
         //image data
         NSData *imageData = nil;
         
//         imageData = [CompressPicturesTool zipImageWithImage:requestModel.uploadImage imageType:ImageQualityStandard];
         //用户在个人中心设置的图片规格
         NSString *imageQ =  [[NSUserDefaults standardUserDefaults] valueForKey:@"indexStr"];
         NSInteger imageIndex = [imageQ integerValue];
         if (imageIndex == 0) {
             imageData = [CompressPicturesTool zipImageWithImage:requestModel.uploadImage imageType:ImageQualityNormal];
         }else if (imageIndex == 1){
             imageData = [CompressPicturesTool zipImageWithImage:requestModel.uploadImage imageType:ImageQualityStandard];
         }else if (imageIndex == 2){
             imageData = [CompressPicturesTool zipImageWithImage:requestModel.uploadImage imageType:ImageQualityHigh];
         }
//         imageData = UIImageJPEGRepresentation(requestModel.uploadImage, 1.0);
         NSLog(@"imageData.length=%ld",imageData.length);
         [formData appendPartWithFileData:imageData
                                     name:@"aFile"
                                 fileName:requestModel.uploadImageName
                                 mimeType:@"image/jpeg"];
     } progress:^(NSProgress * _Nonnull uploadProgress) {

         WSOLog(@"=========== Upload image progress:%@",uploadProgress);
         dispatch_async(dispatch_get_main_queue(), ^{
             if (requestModel.uploadProgressBlock) {
                 requestModel.uploadProgressBlock(uploadProgress);
             }

         });

     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

         WSOLog(@"=========== Upload image request succeed:%@\n =========== Successfully uploaded images:%@",responseObject,requestModel.uploadImages);
         dispatch_async(dispatch_get_main_queue(), ^{

             if (requestModel.successBlock) {
                 requestModel.successBlock(responseObject);
             }

             [weakSelf handleRequestModelFinished:requestModel];

         });


     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         WSOLog(@"=========== Upload images request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed images:%@:",error,(long)error.code,requestModel.uploadImages);
         dispatch_async(dispatch_get_main_queue(), ^{

             if (requestModel.failureBlock) {
                 requestModel.failureBlock(task, error);
             }

             [weakSelf handleRequestModelFinished:requestModel];

         });

     }];    

    requestModel.dataTask = uploadTask;
    [self addRequestModel:requestModel];

}


- (void)p_sendUploadImageRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{
    WSOLog(@"=========== Start upload request with url:%@...",requestModel.requestUrl);

    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *uploadTask = [_uploadSessionManager POST:requestModel.requestUrl
  parameters:requestModel.parameters
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
[requestModel.uploadImageInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull imageInfo, NSUInteger idx, BOOL * _Nonnull stop) {


                 UIImage *image = [imageInfo objectForKey:@"image"];
                 NSString *name = [imageInfo objectForKey:@"name"];
                 NSString *mimeType = [imageInfo objectForKey:@"mimeType"];
                 float ratio = [[imageInfo objectForKey:@"ratio"] floatValue];

                 //image compress ratio
                 if (ratio > 1 || ratio < 0) {
                     ratio = 1;
                 }

                 //image data
                 NSData *imageData = nil;

                 //image type
                 NSString *imageType = nil;

                 if ([mimeType isEqualToString:@"png"] || [mimeType isEqualToString:@"PNG"]  ) {

                     imageData = UIImagePNGRepresentation(image);
                     imageType = @"png";

                 }else if ([mimeType isEqualToString:@"jpg"] || [mimeType isEqualToString:@"JPG"] ){

                     imageData = UIImageJPEGRepresentation(image, ratio);
                     imageType = @"jpg";

                 }else if ([mimeType isEqualToString:@"jpeg"] || [mimeType isEqualToString:@"JPEG"] ){

                     imageData = UIImageJPEGRepresentation(image, ratio);
                     imageType = @"jpeg";

                 }else{
                     imageData = UIImageJPEGRepresentation(image, ratio);
                     imageType = @"jpg";
                 }


                 NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                 long long totalMilliseconds = interval * 1000;

                 //file name should be unique
                 NSString *fileName = [NSString stringWithFormat:@"%lld.%@", totalMilliseconds,imageType];

                 [formData appendPartWithFileData:imageData
                                             name:name
                                         fileName:fileName
                                         mimeType:[NSString stringWithFormat:@"image/%@",imageType]];
             }];

         } progress:^(NSProgress * _Nonnull uploadProgress) {


             WSOLog(@"=========== Upload image progress:%@",uploadProgress);


             dispatch_async(dispatch_get_main_queue(), ^{
                 if (requestModel.uploadProgressBlock) {
                     requestModel.uploadProgressBlock(uploadProgress);
                 }

             });

         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {


             WSOLog(@"=========== Upload image request succeed:%@\n =========== Successfully uploaded images:%@",responseObject,requestModel.uploadImages);


             dispatch_async(dispatch_get_main_queue(), ^{

                 if (requestModel.successBlock) {
                     requestModel.successBlock(responseObject);
                 }

                 [weakSelf handleRequestModelFinished:requestModel];

             });


         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {


             WSOLog(@"=========== Upload images request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed images:%@:",error,(long)error.code,requestModel.uploadImages);


             dispatch_async(dispatch_get_main_queue(), ^{

                 if (requestModel.failureBlock) {
                     requestModel.failureBlock(task, error);
                 }

                 [weakSelf handleRequestModelFinished:requestModel];

             });

         }];

    requestModel.dataTask = uploadTask;
    [self addRequestModel:requestModel];


}
#pragma mark- ============== Private Methods ==============



- (void)p_sendUploadImagesWithImageInfoRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{
    
    WSOLog(@"=========== Start upload request with url:%@...",requestModel.requestUrl);
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *uploadTask = [_uploadSessionManager POST:requestModel.requestUrl
                                                        parameters:requestModel.parameters
                                         constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                             
                                             [requestModel.uploadImageInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull imageInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                                                 
                                                 
                                                 UIImage *image = [imageInfo objectForKey:@"image"];
                                                 NSString *name = [imageInfo objectForKey:@"name"];
                                                 NSString *mimeType = [imageInfo objectForKey:@"mimeType"];
                                                 float ratio = [[imageInfo objectForKey:@"ratio"] floatValue];
                                                 
                                                 //image compress ratio
                                                 if (ratio > 1 || ratio < 0) {
                                                     ratio = 1;
                                                 }
                                                 
                                                 //image data
                                                 NSData *imageData = nil;
                                                 
                                                 //image type
                                                 NSString *imageType = nil;
                                                 
                                                 if ([mimeType isEqualToString:@"png"] || [mimeType isEqualToString:@"PNG"]  ) {
                                                     
                                                     imageData = UIImagePNGRepresentation(image);
                                                     imageType = @"png";
                                                     
                                                 }else if ([mimeType isEqualToString:@"jpg"] || [mimeType isEqualToString:@"JPG"] ){
                                                     
                                                     imageData = UIImageJPEGRepresentation(image, ratio);
                                                     imageType = @"jpg";
                                                     
                                                 }else if ([mimeType isEqualToString:@"jpeg"] || [mimeType isEqualToString:@"JPEG"] ){
                                                     
                                                     imageData = UIImageJPEGRepresentation(image, ratio);
                                                     imageType = @"jpeg";
                                                     
                                                 }else{
                                                     imageData = UIImageJPEGRepresentation(image, ratio);
                                                     imageType = @"jpg";
                                                 }
                                                 
                                                 
                                                 NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                                                 long long totalMilliseconds = interval * 1000;
                                                 
                                                 //file name should be unique
                                                 NSString *fileName = [NSString stringWithFormat:@"%lld.%@", totalMilliseconds,imageType];
                                                 
                                                 [formData appendPartWithFileData:imageData
                                                                             name:name
                                                                         fileName:fileName
                                                                         mimeType:[NSString stringWithFormat:@"image/%@",imageType]];
                                             }];
                                             
                                         } progress:^(NSProgress * _Nonnull uploadProgress) {
                                             
                                             
                                             WSOLog(@"=========== Upload image progress:%@",uploadProgress);
                                             
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (requestModel.uploadProgressBlock) {
                                                     requestModel.uploadProgressBlock(uploadProgress);
                                                 }
                                                 
                                             });
                                             
                                         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                             
                                             
                                             WSOLog(@"=========== Upload image request succeed:%@\n =========== Successfully uploaded images:%@",responseObject,requestModel.uploadImages);
                                             
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 if (requestModel.successBlock) {
                                                     requestModel.successBlock(responseObject);
                                                 }
                                                 
                                                 [weakSelf handleRequestModelFinished:requestModel];
                                                 
                                             });
                                             
                                             
                                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                             
                                             
                                             WSOLog(@"=========== Upload images request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed images:%@:",error,(long)error.code,requestModel.uploadImages);
                                             
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 if (requestModel.failureBlock) {
                                                     requestModel.failureBlock(task, error);
                                                 }
                                                 
                                                 [weakSelf handleRequestModelFinished:requestModel];
                                                 
                                             });
                                             
                                         }];
    
    requestModel.dataTask = uploadTask;
    [self addRequestModel:requestModel];
    
}
- (void)p_sendUploadImagesRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{
    
    
    
    WSOLog(@"=========== Start upload request with url:%@...",requestModel.requestUrl);
    
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *uploadTask = [_uploadSessionManager POST:requestModel.requestUrl
                                                  parameters:requestModel.parameters
                                   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                       
                                       [requestModel.uploadImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
                                           
                                           //image compress ratio
                                           float ratio = requestModel.imageCompressRatio;
                                           if (ratio > 1 || ratio < 0) {
                                               ratio = 1;
                                           }
                                           
                                           //image data
                                           NSData *imageData = nil;
                                           
                                           //image type
                                           NSString *imageType = nil;
                                           
                                           if ([requestModel.mimeType isEqualToString:@"png"] || [requestModel.mimeType isEqualToString:@"PNG"]  ) {
                                               
                                               imageData = UIImagePNGRepresentation(image);
                                               imageType = @"png";
                                               
                                           }else if ([requestModel.mimeType isEqualToString:@"jpg"] || [requestModel.mimeType isEqualToString:@"JPG"] ){
                                               
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpg";
                                               
                                           }else if ([requestModel.mimeType isEqualToString:@"jpeg"] || [requestModel.mimeType isEqualToString:@"JPEG"] ){
                                               
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpeg";
                                               
                                           }else{
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpg";
                                           }
                                           
                                           
                                           long index = idx;
                                           NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                                           long long totalMilliseconds = interval * 1000;
                                           
                                           //file name should be unique
//                                           NSString *fileName = [NSString stringWithFormat:@"%lld.%@", totalMilliseconds,imageType];

                                           //name should be unique
                                           NSString *identifer = [NSString stringWithFormat:@"%@%ld", requestModel.imagesIdentifer, index];

                                           
                                           [formData appendPartWithFileData:imageData
                                                                       name:identifer
                                                                   fileName:requestModel.imageName
                                                                   mimeType:[NSString stringWithFormat:@"image/%@",imageType]];
                                       }];
                                       
                                   } progress:^(NSProgress * _Nonnull uploadProgress) {
                                       
                                       
                                        WSOLog(@"=========== Upload image progress:%@",uploadProgress);
                                       
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (requestModel.uploadProgressBlock) {
                                               requestModel.uploadProgressBlock(uploadProgress);
                                           }
                                           
                                       });
                                       
                                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                       
                                       
                                           WSOLog(@"=========== Upload image request succeed:%@\n =========== Successfully uploaded images:%@",responseObject,requestModel.uploadImages);
                                       
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           if (requestModel.successBlock) {
                                               requestModel.successBlock(responseObject);
                                           }
                                           
                                           [weakSelf handleRequestModelFinished:requestModel];
                                           
                                       });
                                       
                                       
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {                                       
            
                                       
                                          WSOLog(@"=========== Upload images request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed images:%@:",error,(long)error.code,requestModel.uploadImages);
                                       
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           if (requestModel.failureBlock) {
                                               requestModel.failureBlock(task, error);
                                           }
                                           
                                           [weakSelf handleRequestModelFinished:requestModel];
                                           
                                       });
                                       
                                   }];
    
    requestModel.dataTask = uploadTask;
    [self addRequestModel:requestModel];
    
}



#pragma mark Request API using specific request method

- (void)sendRequest:(NSString *)url
             method:(WSORequestMethod)method
         parameters:(id)parameters
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
  
    
  [self sendRequest:url
             method:method
         parameters:parameters
          loadCache:NO
        ignoreToken:nil
      cacheDuration:0
            success:successBlock
            failure:failureBlock];
}

- (void)sendRequest:(NSString *)url
             method:(WSORequestMethod)method
         parameters:(id)parameters
          loadCache:(BOOL)loadCache
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
  [self sendRequest:url
             method:method
         parameters:parameters
          loadCache:loadCache
        ignoreToken:nil
      cacheDuration:0
            success:successBlock
            failure:failureBlock];
}


- (void)sendRequest:(NSString *)url
             method:(WSORequestMethod)method
         parameters:(id)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
  [self sendRequest:url
             method:method
         parameters:parameters
          loadCache:NO
        ignoreToken:nil
      cacheDuration:cacheDuration
            success:successBlock
            failure:failureBlock];
}


- (void)sendRequest:(NSString *)url
             method:(WSORequestMethod)method
         parameters:(id)parameters
          loadCache:(BOOL)loadCache
        ignoreToken:(BOOL)ignoreToken
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock)successBlock
            failure:(WSO2FailureBlock)failureBlock{
    
    

    //generate complete url
    NSString *completeUrlStr = [WSONetworkUtils generateCompleteRequestUrlStrWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                             requestUrlStr:url];
    
    //request method
    NSString *methodStr = nil;
    switch (method) {
            
        case WSORequestMethodGET:{
            methodStr = @"GET";
        }
            break;
            
        case WSORequestMethodPOST:{
            methodStr = @"POST";
        }
            break;

            
        case WSORequestMethodPUT:{
            methodStr = @"PUT";
        }
            break;
    }
    
    //a unique identifer of a spectific request
    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url
                                                                                 method:methodStr
                                                                             parameters:parameters];

    
        //if not load cache, request immediately
        [self sendRequestWithCompleteUrlStr:completeUrlStr
                                     method:methodStr
                                 parameters:parameters
                                  loadCache:loadCache
                                ignoreToken:ignoreToken
                              cacheDuration:cacheDuration
                           requestIdentifer:requestIdentifer
                                    success:successBlock
                                    failure:failureBlock];
    

}



#pragma mark- Private Methods

- (void)sendRequestWithCompleteUrlStr:(NSString *)completeUrlStr
                               method:(NSString *)methodStr
                           parameters:(id)parameters
                            loadCache:(BOOL)loadCache
                          ignoreToken:(BOOL)ignoreToken
                        cacheDuration:(NSTimeInterval)cacheDuration
                     requestIdentifer:(NSString *)requestIdentifer
                              success:(WSO2SuccessBlock)successBlock
                              failure:(WSO2FailureBlock)failureBlock{
    
    //if there is default parameters, add them into request body(POST request only)
    id parameters_spliced = nil;
    if ([methodStr isEqualToString:@"POST"] && [parameters isKindOfClass:[NSDictionary class]] && ([WSONetworkConfig sharedConfig].defailtParameters)) {
        NSMutableDictionary *defaultParameters_m = [[WSONetworkConfig sharedConfig].defailtParameters mutableCopy];
        [defaultParameters_m addEntriesFromDictionary:parameters];
        parameters_spliced = [defaultParameters_m copy];

    }else{
        parameters_spliced = parameters;
    }

    //create corresponding request model and send request with it
    WSONetworkRequestModel *requestModel = [[WSONetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = parameters;
    requestModel.loadCache = loadCache;
    requestModel.cacheDuration = cacheDuration;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = successBlock;
    requestModel.failureBlock = failureBlock;

        NSString *uuid_str = [[UserPreferenceManager defaultManager] getUUIDString];
        NSString *ST = [[UserPreferenceManager defaultManager] getUserStstring];
        NSString *AT = [[UserPreferenceManager defaultManager] getAT];
        //时间戳
        NSString *TIMESTAMP = [NSString getNowTimeTimestamp];
        NSString *paramsStr = [self sortDictionaryWithDic:parameters];
        NSString *saltStr = [[UserPreferenceManager defaultManager] getSaltStr];
//    NSString *serialNum = [[UserPreferenceManager defaultManager] getUserSerialNum];
    NSLog(@"uuid_str=%@,ST=%@,TIMESTAMP=%@,saltStr=%@",uuid_str,ST,TIMESTAMP,saltStr);
            //    NSString *sign =
            //    无 AT。sha1：顺序ST,SERIAL,IMEI,DATA
            //    有AT。 sha1：顺序ST,AT,SERIAL,IMEI,DATA
            
            if (ignoreToken) {
                NSString *scretstr = [NSString stringWithFormat:@"ST=%@&AT=&TIMESTAMP=%@&IMEI=%@&%@",ST,TIMESTAMP,uuid_str,paramsStr];
                NSLog(@"scretstr==%@",scretstr);
                NSString *sha =  [self sha1:scretstr];
                NSLog(@"sha===%@",sha);
                [_sessionManager.requestSerializer setValue:ST forHTTPHeaderField:@"ST"];
                [_sessionManager.requestSerializer setValue:sha forHTTPHeaderField:@"SIGN"];
                [_sessionManager.requestSerializer setValue:@"" forHTTPHeaderField:@"AT"];
                [_sessionManager.requestSerializer setValue:TIMESTAMP forHTTPHeaderField:@"TIMESTAMP"];
                NSLog(@"HeaderTIMESTAMP==%@",TIMESTAMP);
                
            }else{
                NSString *scretstr  = @"";
                if ([self isBlankString:paramsStr]) {
                    scretstr = [NSString stringWithFormat:@"ST=%@&AT=%@&TIMESTAMP=%@&IMEI=%@",ST,AT,TIMESTAMP,uuid_str];
                    NSLog(@"scretstrTIMESTAMP==%@",TIMESTAMP);

                }else{
                    scretstr = [NSString stringWithFormat:@"ST=%@&AT=%@&TIMESTAMP=%@&IMEI=%@&%@",ST,AT,TIMESTAMP,uuid_str,paramsStr];
                    NSLog(@"scretstrTIMESTAMP==%@",TIMESTAMP);

                }
                

                NSLog(@"scretstr==%@",scretstr);
                NSString *sha =  [self sha1:scretstr];
                NSLog(@"sha===%@",sha);

                [_sessionManager.requestSerializer setValue:ST forHTTPHeaderField:@"ST"];
                [_sessionManager.requestSerializer setValue:AT forHTTPHeaderField:@"AT"];
                [_sessionManager.requestSerializer setValue:sha forHTTPHeaderField:@"SIGN"];
                [_sessionManager.requestSerializer setValue:TIMESTAMP forHTTPHeaderField:@"TIMESTAMP"];

            }
        NSLog(@"_sessionManager.requestSerializer.HTTPRequestHeaders=%@",_sessionManager.requestSerializer.HTTPRequestHeaders);

    //create a session task corresponding to a request model
    NSError * __autoreleasing requestSerializationError = nil;
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequestModel:requestModel
                                                  requestSerializer:_sessionManager.requestSerializer
                                                              error:&requestSerializationError];
    requestModel.dataTask = dataTask;

    //put this request model into request cache
    [self addRequestModel:requestModel];

    WSOLog(@"=========== start requesting:\n =========== url:%@\n =========== method:%@\n =========== parameters:%@",completeUrlStr,methodStr,parameters);

    //start request
    [dataTask resume];

}

- (NSMutableDictionary *)getRidOfArrayAndDic:(NSDictionary *)dic{
    if (!dic) {
        return nil;
    }
    NSMutableDictionary *a_dic = [dic mutableCopy];
    [a_dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]] ||[obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) {
            [a_dic removeObjectForKey:key];
        }
    }];
    
    return a_dic;
}

- (NSString *)sortDictionaryWithDic:(NSDictionary *)paramsDic{
    NSMutableDictionary *dic = [paramsDic mutableCopy];

    NSMutableDictionary *sortDic =  [self getRidOfArrayAndDic:dic];
    NSArray *keyArray = [sortDic allKeys];
    
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult result = [obj1 compare:obj2 options:NSNumericSearch];

        return result;
    }];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortArray) {
        [valueArray addObject:[sortDic objectForKey:sortString]];
    }

    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [signArray addObject:keyValueStr];
    }

    NSString *sign = [signArray componentsJoinedByString:@"&"];

    return sign;
}
//sha-1加密
- (NSString *)sha1:(NSString *)input
{
    NSString *saltStr = [[UserPreferenceManager defaultManager] getSaltStr];
    int saltNum = [saltStr intValue];
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%0x", digest[i] & saltNum];
    }
    return output;
}

// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;

}


//====================== Request API uploading =======================//


- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                    parameters:(id)parameters
                         image:(UIImage * _Nonnull)image
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                       success:(WSO2SuccessBlock _Nullable)successBlock
                       failure:(WSO2FailureBlock _Nullable)failureBlock{

    [self sendUploadImagesRequest:url
                    ignoreBaseUrl:NO
                       parameters:parameters
                           images:@[image]
                    compressRatio:1
                             name:name
                         mimeType:mimeType
                         progress:progressBlock
                          success:successBlock
                          failure:failureBlock];

    
}

- (void)sendUploadImagesRequestWithRequestModel:(WSONetworkRequestModel *)requestModel{


    [self addRequestModel:requestModel];
    
    [_sessionManager POST:requestModel.requestUrl parameters:requestModel.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [requestModel.uploadImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //image compress ratio
            float ratio = requestModel.imageCompressRatio;
            if (ratio > 1 || ratio < 0) {
                ratio = 1;
            }
            
            //image data
            NSData *imageData = UIImageJPEGRepresentation(image, ratio);
            long index = idx;
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
            long long totalMilliseconds = interval * 1000;
            
            //file name should be unique
            NSString *fileName = [NSString stringWithFormat:@"%lld.png", totalMilliseconds];
            
            //name should be unique
            NSString *identifer = [NSString stringWithFormat:@"%@%ld", requestModel.imagesIdentifer, index];
            
            //mime type
            NSString *mimeType = nil;
            if (requestModel.mimeType) {
                mimeType = requestModel.mimeType;
            }else{
                mimeType = @"jpeg";
            }
            [formData appendPartWithFileData:imageData
                                        name:identifer
                                    fileName:fileName
                                    mimeType:[NSString stringWithFormat:@"image/%@",mimeType]];
        }];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (requestModel.uploadProgressBlock) {
            requestModel.uploadProgressBlock(uploadProgress);
            [self handleRequestModelFinished:requestModel];
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        WSOLog(@"=========== Upload image request succeed");
        if (requestModel.successBlock) {
            requestModel.successBlock(responseObject);
            //remove this requst model from request queue
            [self handleRequestModelFinished:requestModel];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        WSOLog(@"=========== Upload image request failed");
        if (requestModel.failureBlock) {
            requestModel.failureBlock(task,error);
            //remove this requst model from request queue
            [self handleRequestModelFinished:requestModel];
        }
    }];
    
}



- (NSURLSessionDataTask *)dataTaskWithRequestModel:(WSONetworkRequestModel *)requestModel
                                 requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                             error:(NSError * _Nullable __autoreleasing *)error{
    

    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestModel.method
                                                              URLString:requestModel.requestUrl
                                                             parameters:requestModel.parameters
                                                                  error:error];
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [_sessionManager dataTaskWithRequest:request
                                     uploadProgress:requestModel.uploadProgressBlock
                                   downloadProgress:requestModel.downloadProgressBlock
                                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error){
        
        [self handleRequestModel:requestModel responseObject:responseObject error:error];
    }];
    
    requestModel.dataTask = dataTask;
    
    return dataTask;
    
}


- (void)handleRequestModel:(WSONetworkRequestModel *)requestModel
            responseObject:(id)responseObject
                     error:(NSError *)error{
    
    NSError *requestError = nil;
    BOOL requestSucceed = YES;
    
    //check request state
    if (error) {
        requestSucceed = NO;
        requestError = error;
    }
    
    if (requestSucceed) {

        //call success block
        requestModel.responseObject = responseObject;
        [self requestDidSucceedWithRequestModel:requestModel];
        
    } else {
        
        //call failed block
        [self requestDidFailedWithRequestModel:requestModel error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self handleRequestModelFinished:requestModel];
        
    });
    
}

- (void)handleRequestModelFinished:(WSONetworkRequestModel *)requestModel{

    //remove this requst model from request queue
    [self removeRequestModel:requestModel];
    [requestModel clearAllBlocks];
    
}


- (void)requestDidSucceedWithRequestModel:(WSONetworkRequestModel *)requestModel{
    
    //write cache
    if (requestModel.cacheDuration > 0) {
        if (requestModel.responseObject) {
            requestModel.responseData = [NSJSONSerialization dataWithJSONObject:requestModel.responseObject options:NSJSONWritingPrettyPrinted error:nil];
        }
        [[WSONetworkCacheManager sharedManager] writeCacheWithReqeustModel:requestModel asynchronously:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (requestModel.successBlock) {
            WSOLog(@"=========== Request succeed via network & response object:%@",requestModel.responseObject);
            requestModel.successBlock(requestModel.responseObject);
        }
    });
}


- (void)requestDidFailedWithRequestModel:(WSONetworkRequestModel *)requestModel
                                   error:(NSError *)error{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (requestModel.failureBlock){
            WSOLog(@"=========== Request failded via network error:%@",error);
            requestModel.failureBlock(requestModel.dataTask, error);
        }
    });
}

- (void)addRequestModel:(WSONetworkRequestModel *)requestModel{
    
    Lock();
    [self.currentRequestModels setObject:requestModel forKey:[NSString stringWithFormat:@"%@",@(requestModel.dataTask.taskIdentifier)]];
    Unlock();
}

- (void)removeRequestModel:(WSONetworkRequestModel *)requestModel{
    
    Lock();
    [self.currentRequestModels removeObjectForKey:[NSString stringWithFormat:@"%@",@(requestModel.dataTask.taskIdentifier)]];
    Unlock();
    
}



#pragma mark- Request Info

- (BOOL)remainingCurrentRequests{

    NSArray *keys = [self.currentRequestModels allKeys];
    if ([keys count]>0) {
        WSOLog(@"=========== There is remaining current request");
        return YES;
    }
    WSOLog(@"=========== There is no remaining current request");
    return NO;
}


- (NSInteger)currentRequestCount{

    NSArray *keys = [self.currentRequestModels allKeys];
    WSOLog(@"=========== There is %ld current request",keys.count);
    return [keys count];
    
}


- (void)logAllCurrentRequests{
    
    if ([self remainingCurrentRequests]) {
        for (WSONetworkRequestModel *model in [self.currentRequestModels allValues]) {
            WSOLog(@"=========== log current request:\n %@",model);
        }
    }else{
        WSOLog(@"=========== There is no any current request");
    }
    
}



#pragma mark- Cancel Request

- (void)cancelAllCurrentRequests{
    
    if ([self remainingCurrentRequests]) {
        
        for (WSONetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
            [requestModel.dataTask cancel];
            [self removeRequestModel:requestModel];
        }
        WSOLog(@"=========== Canceled call current requests");
        
    }
}


- (void)cancelCurrentRequestWithUrl:(NSString *)url{
    
    NSMutableArray *cancelRequestsArr = [NSMutableArray arrayWithCapacity:2];
    for (WSONetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
        
        NSString *url = requestModel.requestUrl;
        if ([url isEqualToString:requestModel.requestUrl]) {
            [requestModel.dataTask cancel];
            WSOLog(@"=========== Canceled request with url:%@",requestModel.requestUrl);
            [cancelRequestsArr addObject:requestModel];
        }
    }
    
    if ([cancelRequestsArr count]>0) {
        for (WSONetworkRequestModel *requestModel in cancelRequestsArr) {
            [self removeRequestModel:requestModel];
        }
        [cancelRequestsArr removeAllObjects];
    }
    
}

//多个task
- (void)cancelCurrentRequestWithUrl:(NSString *)url
                         parameters:(NSDictionary *)parameters{
    
    //default method is POST
    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url method:@"POST"parameters:parameters];
    
    NSMutableArray *cancelRequestsArr = [NSMutableArray arrayWithCapacity:2];
    for (WSONetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
        
        if ([requestIdentifer isEqualToString:requestModel.requestIdentifer]) {
            [requestModel.dataTask cancel];
            WSOLog(@"=========== Canceled request with url:%@",requestModel.requestUrl);
            [cancelRequestsArr addObject:requestModel];
        }
    }
    
    if ([cancelRequestsArr count]>0) {
        for (WSONetworkRequestModel *requestModel in cancelRequestsArr) {
             [self removeRequestModel:requestModel];
        }
        [cancelRequestsArr removeAllObjects];
    }
}

- (void)cancelCurrentRequestWithUrl:(NSString *)url
                             method:(NSString *)method
                         parameters:(NSDictionary *)parameters{
    
    
    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url method:method
                                                                             parameters:parameters];
    
    NSMutableArray *cancelRequestsArr = [NSMutableArray arrayWithCapacity:2];
    for (WSONetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
        
        if ([requestIdentifer isEqualToString:requestModel.requestIdentifer]) {
            [requestModel.dataTask cancel];
            WSOLog(@"=========== Canceled request with url:%@",requestModel.requestUrl);
            [cancelRequestsArr addObject:requestModel];
        }
    }
    
    if ([cancelRequestsArr count]>0) {
        for (WSONetworkRequestModel *requestModel in cancelRequestsArr) {
            [self removeRequestModel:requestModel];
        }
        [cancelRequestsArr removeAllObjects];
    }
    
}

#pragma mark- Cache Operations



#pragma mark Load cache


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
     withCompletionBlock:(WSOLoadCacheArrCompletionBlock _Nullable)completionBlock{

     [[WSONetworkCacheManager sharedManager] loadCacheWithUrl:url
                                         withCompletionBlock:completionBlock];
}


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock{
    
     [[WSONetworkCacheManager sharedManager] loadCacheWithUrl:url
                                                  parameters:parameters
                                         withCompletionBlock:completionBlock];

}



- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock{
    
     [[WSONetworkCacheManager sharedManager] loadCacheWithUrl:url
                                                      method:method
                                                  parameters:parameters
                                         withCompletionBlock:completionBlock];
}



#pragma mark calculate cache

- (void)calculateCacheSizeWithCompletionBlock:(WSOCalculateSizeCompletionBlock _Nullable)completionBlock{

    [[WSONetworkCacheManager sharedManager] calculateCacheSizeWithCompletionBlock:completionBlock];
}




#pragma mark clear cache

- (void)clearAllCacheWithCompletionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    [[WSONetworkCacheManager sharedManager] clearAllCacheWithCompletionBlock:completionBlock];
}


- (void)clearCacheWithUrl:(NSString * _Nonnull)url
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{
    
    [[WSONetworkCacheManager sharedManager] clearCacheWithUrl:url
                                             completionBlock:completionBlock];

}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{
    
    [[WSONetworkCacheManager sharedManager] clearCacheWithUrl:url
                                                  parameters:parameters
                                             completionBlock:completionBlock];

}


- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{
    
    [[WSONetworkCacheManager sharedManager] clearCacheWithUrl:url
                                                      method:method
                                                  parameters:parameters
                                             completionBlock:completionBlock];

}


#pragma mark- Setter and Getters

//current request queue
- (WSOCurrentRequestModels *)currentRequestModels {
    
    WSOCurrentRequestModels *currentTasks = objc_getAssociatedObject(self, &currentRequestModelsKey);
    if (currentTasks) {
        return currentTasks;
    }
    currentTasks = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &currentRequestModelsKey, currentTasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return currentTasks;
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
