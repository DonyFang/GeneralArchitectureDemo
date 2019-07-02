//
//  WSONetworkCache.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSONetworkRequestModel;



// Callback when the cache is cleared
typedef void(^WSOClearCacheCompletionBlock)(BOOL isSuccess);

// Callback when the cache is loaded
typedef void(^WSOLoadCacheCompletionBlock)(id _Nullable cacheObject);

// Callback when cache of cache array is loaded
typedef void(^WSOLoadCacheArrCompletionBlock)(NSArray * _Nullable cacheArr);

// Callback when the size of cache calculated
typedef void(^WSOCalculateSizeCompletionBlock)(NSUInteger fileCount, NSUInteger totalSize);



/* =============================
 *
 * WSONetworkCacheManager
 *
 * WSONetworkCacheManager is in charge of managing operations of cache
 *
 * =============================
 */

@interface WSONetworkCacheManager : NSObject



/**
 *  WSONetworkCacheManager Singleton
 *
 *  @return WSONetworkCacheManager singleton instance
 */
+ (WSONetworkCacheManager *_Nonnull)sharedManager;





//============================ Write Cache ============================//

/**
 *  This method is used to write cache(cache data and cache info), 
    can only be called by WSONetworkManager instance
 *
 *  @param requestModel        the model holds the configuration of a specific request
 *  @param asynchronously      if write cache asynchronously
 *
 */
- (void)writeCacheWithReqeustModel:(WSONetworkRequestModel * _Nonnull)requestModel
                    asynchronously:(BOOL)asynchronously;






//============================= Load cache =============================//


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


/**
 *  This method is used to load cache which is related to a identier which is the unique to a network request,
    can only be called by WSONetworkManager instance
 *
 *  @param requestIdentifer     the unique identier of a specific request
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer
                  withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock;





//============================ calculate cache ============================//

/**
 *  This method is used to calculate the size of the cache folder
 *
 *  @param completionBlock      callback
 *
 */
- (void)calculateCacheSizeWithCompletionBlock:(WSOCalculateSizeCompletionBlock _Nullable)completionBlock;





//============================== clear cache ==============================//

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





//==================== Cache data and cache info file path ====================//

/**
 *  This method is used to generate the full path of cache data file,
    corresponding to a unique identifer to the network request
 *
 *  @param requestIdentifer      the unique identier of a specific network request
 *
 *  @return the full path of cache data file
 */
- (NSString * _Nullable)cacheDataFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer;



/**
 *  This method is used to generate the full path of cache info file,
    corresponding to a unique identifer to the network request
 *
 *  @param requestIdentifer      the unique identier of a specific network request
 *
 *  @return the full path of cache info file
 */
- (NSString * _Nullable)cacheInfoFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer;


@end
