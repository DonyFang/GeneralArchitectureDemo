//
//  WSONetworkManager.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WSONetworkRequestModel.h"
#import "WSONetworkCacheManager.h"

/* =============================
 *
 * WSONetworkManager
 *
 * WSONetworkManager is in charge of managing operations of network request
 *
 * =============================
 */

@interface WSONetworkManager : NSObject

@property (nonatomic, strong) NSDictionary * _Nullable tokenHeader;

/**
 *  WSONetworkManager Singleton
 *
 *  @return WSONetworkManager singleton instance
 */
+ (WSONetworkManager *_Nonnull)sharedManager;

/**
 *  can not use new method
 */
+ (instancetype _Nonnull)new NS_UNAVAILABLE;



//================== Request API using specific request method ==================//

/**
 *  These methods are used to send request specific request method:
 
    1. if the method is set to be 'WSORequestMethodGET', then send GET request
    2. if the method is set to be 'WSORequestMethodPOST', then send POST request
 */

/**
 *  This method is used to send request with specific method(GET or POST),
 *  consider whether to load cache and whether to write cache after request finished.
 *
 *  @note:
 *        1. All the other request API will call this method.
 *
 *        2. If 'loadCache' is set to be YES, then cache will be tried to
 *           load before request network no matter if the cache exists:
 *           If it exists,then load it and callback immediately.
 *           If it dose not exist,then send real network request.
 *
 *           If 'loadCache' is set to be NO, then no matter if the cache
 *           exists,real network request will be sent.
 *
 *        3. If 'cacheDuration' is set to be large than 0,
 *           then the cache of this request will be written and
 *           the time of duration of this cache will be equal to 'cacheDuration'.
 *
 *           So,if the past time is longer than the time duration,
 *           real network request will be sent.
 *
 *           If 'cacheDuration' is set to be less or equal to 0, then the cache
 *           of this request will not be written.
 *
 *           The unit of cacheDuration is second.
 *
 *  @param url                request url
 *  @param method             request method
 *  @param parameters         parameters
 *  @param loadCache          consider whether to load cache
 *  @param cacheDuration      consider whether to write cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
             method:(WSORequestMethod)method
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
        ignoreToken:(BOOL)ignoreToken
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send request with specific method(GET or POST),
    not consider whether to load cache but consider whether to write cache
 *
 *  @param url                request url
 *  @param method             request method
 *  @param parameters         parameters
 *  @param cacheDuration      consider whether to write cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
             method:(WSORequestMethod)method
         parameters:(id _Nullable)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send request with specific method(GET or POST),
    not consider whether to write cache but consider whether to load cache
 *
 *  @param url                request url
 *  @param method             request method
 *  @param parameters         parameters
 *  @param loadCache          consider whether to load cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
             method:(WSORequestMethod)method
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send request with specific method(GET or POST),
    not consider whether to write cache & not consider whether to load cache
 *
 *  @param url                 request url
 *  @param method              request method
 *  @param parameters          parameters
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
             method:(WSORequestMethod)method
         parameters:(id _Nullable)parameters
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;




//================== Request API with specific parameters ==================//


/**
 *  These methods are used to send request with specific parameters:
 
        1. if the parameters object is nil,then send GET request
        2. if the parameters object is not nil,then send POST request
 */


/**
 *  This method is used to send request with specific parameters,
    consider whether to load cache and consider whether to write cache
 
 *
 *  @param url                request url
 *  @param parameters         parameters
 *  @param loadCache          consider whether to load cache
 *  @param cacheDuration      consider whether to write cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 * This method is used to send request with specific parameters,
   not consider whether to load cache but consider whether to write cache
 
 *
 *  @param url                request url
 *  @param parameters         parameters
 *  @param cacheDuration      consider whether to write cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;




/**
 *  This method is used to send request with specific parameters,
    not consider whether to write cache but consider whether to load cache
 
 *
 *  @param url                request url
 *  @param parameters         parameters
 *  @param loadCache          consider whether to load cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;




/**
 *  This method is used to send request with specific parameters,
    not consider whether to write cache & not consider whether to load cache
 *
 *  @param url                request url
 *  @param parameters         parameters
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
            success:(WSO2SuccessBlock _Nullable)successBlock
            failure:(WSO2FailureBlock _Nullable)failureBlock;





//====================== Request API using GET method =======================//

/**
 *  This method is used to send GET request,
    consider whether to load cache and consider whether to write cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param loadCache           consider whether to load cache
 *  @param cacheDuration       consider whether to write cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSO2SuccessBlock _Nullable)successBlock
               failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send GET request,
    consider whether to write cache but not consider whether to load cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param cacheDuration       consider whether to write cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(WSO2SuccessBlock _Nullable)successBlock
               failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send GET request,
    consider whether to load cache but not consider whether to write cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param loadCache           consider whether to load cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
               success:(WSO2SuccessBlock _Nullable)successBlock
               failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send GET request,
    not consider whether to write cache & not consider whether to load cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
               success:(WSO2SuccessBlock _Nullable)successBlock
               failure:(WSO2FailureBlock _Nullable)failureBlock;






//====================== Request API using POST method =======================//


/**
 *  This method is used to send POST request,
    consider whether to load cache and consider whether to write cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param loadCache           consider whether to load cache
 *  @param cacheDuration       consider whether to write cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nonnull)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSO2SuccessBlock _Nullable)successBlock
                failure:(WSO2FailureBlock _Nullable)failureBlock;


/**
 *  This method is used to send POST request,
    consider whether to write cache but not consider whether to load cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param cacheDuration       consider whether to write cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nonnull)parameters
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(WSO2SuccessBlock _Nullable)successBlock
                failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send POST request,
    consider whether to load cache but not consider whether to write cache
 *
 *  @param url                 request url
 *  @param parameters          parameters
 *  @param loadCache           consider whether to load cache
 *  @param successBlock        success callback
 *  @param failureBlock        failure callback
 *
 */
- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nonnull)parameters
              loadCache:(BOOL)loadCache
                success:(WSO2SuccessBlock _Nullable)successBlock
                failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to send POST request,
    not consider whether to write cache & not consider whether to load cache
 *
 *  @param url                request url
 *  @param parameters         parameters
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nonnull)parameters
                success:(WSO2SuccessBlock _Nullable)successBlock
                failure:(WSO2FailureBlock _Nullable)failureBlock;



//========================= Request API upload images ==========================//

/**
 *  These methods are used to upload images(or only one image)
 */

/**
 *  This method is used to upload images(or only one image)
 
 *  @note:
 *        1. All the other upload image API will call this method.
 *
 *        2. If 'ignoreBaseUrl' is set to be YES, the base url which is holden by
 *           WSONetworkConfig will be ignored, so 'url' will be the complete request
 *           url of this request.
 *
 *        3. 'name' is the name of image(or images). When uploading more than one
 *           image, a new unique name of one single image will be generated in method
 *           implementation.
 *
 *  @param url                   request url
 *  @param ignoreBaseUrl         consider whether ignore configured base url
 *  @param parameters            parameters
 *  @param images                UIImage object array
 *  @param compressRatio         compress ratio of images
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                        success:(WSO2SuccessBlock _Nullable)successBlock
                        failure:(WSO2FailureBlock _Nullable)failureBlock;

/**
 *  This method is used to upload images(or only one image)
 *
 *  @param url                   request url
 *  @param parameters            parameters
 *  @param images                UIImage object array
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                        success:(WSO2SuccessBlock _Nullable)successBlock
                        failure:(WSO2FailureBlock _Nullable)failureBlock;



/**
 *  This method is used to upload images(or only one image)
 *
 *  @param url                   request url
 *  @param ignoreBaseUrl         consider whether ignore configured base url
 *  @param parameters            parameters
 *  @param images                UIImage object array
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                        success:(WSO2SuccessBlock _Nullable)successBlock
                        failure:(WSO2FailureBlock _Nullable)failureBlock;


/**
 *  This method is used to upload images(or only one image)
 *
 *  @param url                   request url
 *  @param parameters            parameters
 *  @param images                UIImage object array
 *  @param compressRatio         compress ratio of images
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                        success:(WSO2SuccessBlock _Nullable)successBlock
                        failure:(WSO2FailureBlock _Nullable)failureBlock;




/**
 *  This method is used to upload image
 *
 *  @param url                   request url
 *  @param parameters            parameters
 *  @param image                 UIImage object
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                       success:(WSO2SuccessBlock _Nullable)successBlock
                       failure:(WSO2FailureBlock _Nullable)failureBlock;


//上传单张图片
- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                 ignoreBaseUrl:(BOOL)ignoreBaseUrl
                    parameters:(id _Nullable)parameters
                        images:(UIImage* _Nonnull)image
                 compressRatio:(float)compressRatio
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                       success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                       failure:(WSO2FailureBlock _Nullable)uploadFailureBlock;

/**
 *  This method is used to upload image
 *
 *  @param url                   request url
 *  @param ignoreBaseUrl         consider whether ignore configured base url
 *  @param parameters            parameters
 *  @param image                 UIImage object
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                 ignoreBaseUrl:(BOOL)ignoreBaseUrl
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                       success:(WSO2SuccessBlock _Nullable)successBlock
                       failure:(WSO2FailureBlock _Nullable)failureBlock;


/**
 *  This method is used to upload image
 *
 *  @param url                   request url
 *  @param parameters            parameters
 *  @param image                 UIImage object
 *  @param compressRatio         compress ratio of images
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                 compressRatio:(float)compressRatio
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                       success:(WSO2SuccessBlock _Nullable)successBlock
                       failure:(WSO2FailureBlock _Nullable)failureBlock;

/**
 *  This method is used to upload image
 *
 *  @param url                   request url
 *  @param ignoreBaseUrl         consider whether ignore configured base url
 *  @param parameters            parameters
 *  @param image                 UIImage object
 *  @param compressRatio         compress ratio of images
 *  @param name                  file name
 *  @param mimeType              file tyle
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                 ignoreBaseUrl:(BOOL)ignoreBaseUrl
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                 compressRatio:(float)compressRatio
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                       success:(WSO2SuccessBlock _Nullable)successBlock
                       failure:(WSO2FailureBlock _Nullable)failureBlock;


/**
 *  This method is used to upload image
 *
 *  @param url                   request url
 *  @param ignoreBaseUrl         consider whether ignore configured base url
 *  @param parameters            parameters
 *  @param imageInfos            Image infos
 *  @param progressBlock         progress callback
 *  @param successBlock          success callback
 *  @param failureBlock          failure callback
 *
 */
- (void)sendUploadImagesRequest:(NSString *_Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                     imageInfos:(NSArray * _Nonnull)imageInfos
                       progress:(WSO2UploadProgressBlock _Nullable)progressBlock
                        success:(WSO2SuccessBlock _Nullable)successBlock
                        failure:(WSO2FailureBlock _Nullable)failureBlock;

//============================== Requests info ==============================//


/**
 *  This method is used to log all current requests' information
 */
- (void)logAllCurrentRequests;



/**
 *  This method is used to check if there is remaining curent request
 *
 *  @return if there is remaining requests
 */
- (BOOL)remainingCurrentRequests;



/**
 *  This method is used to calculate the count of current requests
 *
 *  @return the count of current requests
 */
- (NSInteger)currentRequestCount;




//============================= Cancel requests =============================//


/**
 *  This method is used to cancel all current requests
 */
- (void)cancelAllCurrentRequests;


/**
 *  This method is used to cancel all current requests corresponding a reqeust url,
    no matter what the method is and parameters are
 *
 *  @param url              request url
 *
 */
- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url;


/**
 *  This method is used to cancel all current requests corresponding a specific reqeust url
    and parameters, the method is acquiescently set to be POST
 *
 *  @param url              request url
 *  @param parameters       parameters
 *
 */
- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url
                         parameters:(NSDictionary * _Nonnull)parameters;


/**
 *  This method is used to cancel all current requests corresponding a specific reqeust url, method and parameters
 *
 *  @param url              request url
 *  @param method           request method
 *  @param parameters       parameters
 *
 */
- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url
                             method:(NSString * _Nonnull)method
                         parameters:(NSDictionary * _Nonnull)parameters;




//============================= Cache operations ==============================//


//=============================== Load cache ==================================//

/**
 *  This method is used to load cache which is related to a specific url,
    no matter what request method is or parameters are
 *
 *
 *  @param url                  the url of related network requests
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithUrl:(NSString * _Nonnull)url
     withCompletionBlock:(WSOLoadCacheArrCompletionBlock _Nullable)completionBlock;



/**
 *  This method is used to load cache which is related to a url with parameters,
    the method is acquiescently set to be POST
 *
 *
 *  @param url                  the url of the network request
 *  @param parameters           the parameters of the network request
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithUrl:(NSString * _Nonnull)url
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock;


/**
 *  This method is used to load cache which is related to a specific url,method and parameters
 *
 *  @param url                  the url of the network request
 *  @param method               the method of the network request
 *  @param parameters           the parameters of the network request
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock;




//=============================== calculate cache ===========================//

/**
 *  This method is used to calculate the size of the cache folder
 *
 *  @param completionBlock      callback
 *
 */
- (void)calculateCacheSizeWithCompletionBlock:(WSOCalculateSizeCompletionBlock _Nullable)completionBlock;





//================================= clear cache ==============================//

/**
 *  This method is used to clear all cache which is in the cache file
 *
 *  @param completionBlock      callback
 *
 */
- (void)clearAllCacheWithCompletionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock;


/**
 *  This method is used to clear the cache which is related the specific url,
    no matter what request method is or parameters are
 *
 *  @param url                   the url of network request
 *  @param completionBlock       callback
 *
 */
- (void)clearCacheWithUrl:(NSString * _Nonnull)url
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock;


/**
 *  This method is used to clear the cache which is related to a specific url and parameters
    the method is acquiescently set to be POST
 *
 *  @param url                  the url of the network request
 *  @param parameters           the parameters of the network request
 *
 *  @param completionBlock      callback
 *
 */
- (void)clearCacheWithUrl:(NSString * _Nonnull)url
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock;


/**
 *  This method is used to clear cache which is related to a specific url,method and parameters
 *
 *  @param url                  the url of the network request
 *  @param method               the method of the network request
 *  @param parameters           the parameters of the network request
 *  @param completionBlock      callback
 *
 */
- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock;

//上传文件
- (void)sendUploadFileRequest:(NSString * _Nonnull)url
                ignoreBaseUrl:(BOOL)ignoreBaseUrl
                   parameters:(id _Nullable)parameters
                     fileData:(NSData * _Nonnull)fileData
                         name:(NSString * _Nonnull)name
                     mimeType:(NSString * _Nullable)mimeType
                     progress:(WSO2UploadProgressBlock _Nullable)uploadProgressBlock
                      success:(WSO2SuccessBlock _Nullable)uploadSuccessBlock
                      failure:(WSO2FailureBlock _Nullable)uploadFailureBlock;

@end
