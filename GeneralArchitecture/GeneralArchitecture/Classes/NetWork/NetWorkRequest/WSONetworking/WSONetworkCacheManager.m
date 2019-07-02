//
//  WSONetworkCache.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSONetworkCacheManager.h"
//#import "WSONetworkCacheInfo.h"
#import "WSONetworkRequestModel.h"
#import "WSONetworkConfig.h"
#import "WSONetworkUtils.h"


#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif


static dispatch_queue_t wso_cache_io_queue() {
    
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.wso.caching.io", attr);
    });
    
    return queue;
}

/* =============================
 *
 * WSONetworkCacheInfo
 *
 * WSONetworkCacheInfo is in charge of recording the infomation of cache which is related to a specific network request
 *
 * =============================
 */

@interface WSONetworkCacheInfo : NSObject<NSSecureCoding>

// Record the creation date of the cache
@property (nonatomic, readwrite, strong) NSDate *creationDate;

// Record the length of the period of validity
@property (nonatomic, readwrite, strong) NSNumber *cacheDuration;

// Record the app version when the cache is created
@property (nonatomic, readwrite, copy)   NSString *appVersionStr;

// Record the request identifier of the cache
@property (nonatomic, readwrite, copy)   NSString *reqeustIdentifer;

@end

@implementation WSONetworkCacheInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.cacheDuration forKey:NSStringFromSelector(@selector(cacheDuration))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionStr forKey:NSStringFromSelector(@selector(appVersionStr))];
    [aCoder encodeObject:self.reqeustIdentifer forKey:NSStringFromSelector(@selector(reqeustIdentifer))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.cacheDuration = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(cacheDuration))];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionStr = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionStr))];
    self.reqeustIdentifer = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(reqeustIdentifer))];
    
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{cacheDuration:%@},{creationDate:%@},{appVersion:%@},{requestIdentifer:%@}",_cacheDuration,_creationDate,_appVersionStr,_reqeustIdentifer];
}

@end




@interface WSONetworkCacheManager()

@property (nonatomic, copy) NSString *cacheBasePath;


@end


@implementation WSONetworkCacheManager{

    NSFileManager *_fileManager;
    BOOL _isDebugMode;
}

+ (WSONetworkCacheManager *_Nonnull)sharedManager{
    
    static WSONetworkCacheManager *sharedManager = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[WSONetworkCacheManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        _cacheBasePath = [WSONetworkUtils createBasePathWithFolderName:@"WSORequestCache"];
        _fileManager = [[NSFileManager alloc] init];
        _isDebugMode = [WSONetworkConfig sharedConfig].debugMode;
    }
    return self;
}

//==================== Write Cache ====================//

#pragma mark- Write Cache

- (void)writeCacheWithReqeustModel:(WSONetworkRequestModel *)requestModel
                    asynchronously:(BOOL)asynchronously{
    
    if (asynchronously) {
        
        dispatch_async(wso_cache_io_queue(), ^{
            [self wrtieCacheWithRequestModel:requestModel];
        });
        
    }else{
        
        [self wrtieCacheWithRequestModel:requestModel];
    }
}

- (void)wrtieCacheWithRequestModel:(WSONetworkRequestModel *)requestModel{
    
    if (requestModel.responseData) {
        
        //write response data
        [requestModel.responseData writeToFile:[self cacheDataFilePathWithRequestIdentifer:requestModel.requestIdentifer] atomically:YES];
        NSDate *createDate = [NSDate date];
        
        //write cache info data
        WSONetworkCacheInfo *cacheInfo = [[WSONetworkCacheInfo alloc] init];
        cacheInfo.creationDate = createDate;
        cacheInfo.cacheDuration = [NSNumber numberWithInteger:requestModel.cacheDuration];
        cacheInfo.appVersionStr = [WSONetworkUtils appVersionStr];
        cacheInfo.reqeustIdentifer = requestModel.requestIdentifer;
        [NSKeyedArchiver archiveRootObject:cacheInfo toFile:[self cacheInfoFilePathWithRequestIdentifer:requestModel.requestIdentifer]];
        
        if (_isDebugMode) {
            WSOLog(@"=========== Save cache succeed : %@",requestModel.responseObject);
        }
        
        
    }else{
        if (_isDebugMode) {
            WSOLog(@"=========== Save cache failed:lost responeseData");
        }
        
    }
}

#pragma mark- Load Cache

- (void)loadCacheWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer
                  withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock{
    
    
    //load cache info
    NSString *cacheInfoFilePath = [self cacheInfoFilePathWithRequestIdentifer:requestIdentifer];
    WSONetworkCacheInfo *cacheInfo = [self loadCacheInfoWithFilePath:cacheInfoFilePath];
    if (!cacheInfo) {
        
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache failed: Faild to load cache info");
        }
        if (completionBlock) {
            
            completionBlock(nil);
            return;
        }
    }
    
    BOOL cacheValidation = [self checkCacheValidation:cacheInfo];
    if (!cacheValidation) {
        
        
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache failed: Cache info is invalid");
        }
        if (completionBlock) {
            completionBlock(nil);
            return;
        }
        
    }
    
    NSString *cacheDataFilePath = [self cacheDataFilePathWithRequestIdentifer:requestIdentifer];
    
    id cacheObject = [self loadCacheObjectWithCacheFilePath:cacheDataFilePath];
    
    if (!cacheObject) {
        
            if (_isDebugMode) {
                WSOLog(@"=========== Load cache failed: Cache data is missing");
            }
        
            if (completionBlock) {
                
                completionBlock(nil);
                 return;
            }
        
    }else {
    
        
            if (_isDebugMode) {
                WSOLog(@"=========== Load cache succeed: Cache loacation:%@",cacheDataFilePath);
            }
            if (completionBlock) {
                completionBlock(cacheObject);
                return;
                
            }
    }
    
    
}

- (BOOL)checkCacheValidation:(WSONetworkCacheInfo *)cacheInfo{
    
    if (!cacheInfo || ![cacheInfo isKindOfClass:[WSONetworkCacheInfo class]]) {
        return NO;
    }

    //check duration
    NSDate *creationDate = cacheInfo.creationDate;
    NSTimeInterval pastDuration = - [creationDate timeIntervalSinceNow];
    NSTimeInterval cacheDuration = [cacheInfo.cacheDuration integerValue];
    
    if (cacheDuration <= 0 ) {
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache info failed:Did not set duration time");
        }
        [self clearCacheWithString:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;        
    }
    
    
    if (pastDuration < 0 || pastDuration > cacheDuration) {
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache info failed:Cache is expired");
        }
        [self clearCacheWithString:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    
    //check app version
    NSString *cacheAppVersionStr = cacheInfo.appVersionStr;
    NSString *currentAppVersionStr = [WSONetworkUtils appVersionStr];
    
    if ( (!cacheAppVersionStr) && (!currentAppVersionStr)) {
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache info failed:Failed to load app version");
        }
        [self clearCacheWithString:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    if (cacheAppVersionStr.length != currentAppVersionStr.length || ![cacheAppVersionStr isEqualToString:currentAppVersionStr]) {
        if (_isDebugMode) {
            WSOLog(@"=========== Load cache info failed:Failed to match app version");
        }
        [self clearCacheWithString:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    return YES;

}


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
     withCompletionBlock:(WSOLoadCacheArrCompletionBlock _Nullable)completionBlock{
        
        NSString *host_md5 =         [WSONetworkUtils generateMD5StringFromString: [NSString stringWithFormat:@"Host:%@",[WSONetworkConfig sharedConfig].baseUrl]];
        NSString *url_md5 =          [WSONetworkUtils generateMD5StringFromString: [NSString stringWithFormat:@"Url:%@",url]];
        NSString *requestIdentifer = [NSString stringWithFormat:@"%@_%@",host_md5,url_md5];
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.cacheBasePath];
        NSMutableArray *requestIdentifersArr = [[NSMutableArray alloc] initWithCapacity:2];
        
        for (NSString *fileName in enumerator){
            if ([fileName containsString:requestIdentifer] && (![fileName containsString:@".cacheInfo"])) {
                [requestIdentifersArr addObject:fileName];
            }
        }
        
        if ([requestIdentifersArr count] > 0) {
            NSMutableArray *cacheObjArr = [[NSMutableArray alloc] initWithCapacity:2];
            
            for (NSString* requestIdentifer in requestIdentifersArr) {
                   [self loadCacheWithRequestIdentifer:requestIdentifer withCompletionBlock:^(id  _Nullable cacheObject) {
                        [cacheObjArr addObject:cacheObject];
                   }];
            }
            
            if (_isDebugMode) {
                WSOLog(@"=========== Load cache succeed: Found cache corresponding this url");
            }
            if (completionBlock) {
                completionBlock([cacheObjArr copy]);
                return;

            }
            
        }else{
            
            if (_isDebugMode) {
                WSOLog(@"=========== Load cache failed: There is no any cache corresponding this url");
            }
            if (completionBlock) {
                completionBlock(nil);
                return;
            }
        }

}


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock{
    
    [self loadCacheWithUrl:url method:@"POST" parameters:parameters withCompletionBlock:^(id  _Nullable cacheObject) {
        if (completionBlock) {
            completionBlock(cacheObject);
        }
    }];
    
}


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nonnull)parameters
     withCompletionBlock:(WSOLoadCacheCompletionBlock _Nullable)completionBlock{

    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl requestUrlStr:url method:method parameters:parameters];
    
    [self loadCacheWithRequestIdentifer:requestIdentifer withCompletionBlock:^(id  _Nullable cacheObject) {
        if (completionBlock) {
            completionBlock(cacheObject);
        }
    }];
    
}



- (WSONetworkCacheInfo *)loadCacheInfoWithFilePath:(NSString *)filePath {
    
    WSONetworkCacheInfo *cacheInfo = nil;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:nil]) {
            cacheInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            if ([cacheInfo isKindOfClass:[WSONetworkCacheInfo class]]) {
                return cacheInfo;
            }else{
                return nil;
            }
    }
    return nil;
}

- (id)loadCacheObjectWithCacheFilePath:(NSString *)cacheFilePath{
    
    id cacheObject = nil;
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheFilePath isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:cacheFilePath];
        cacheObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error];
        if (cacheObject) {
            return cacheObject;
        }
    }
    return cacheObject;
}

#pragma mark- Calculate Cache

- (void)calculateCacheSizeWithCompletionBlock:(WSOCalculateSizeCompletionBlock _Nullable)completionBlock{

    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.cacheBasePath isDirectory:YES];
    
    dispatch_async(wso_cache_io_queue(), ^{
        
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];

        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += fileSize.unsignedIntegerValue;
            fileCount += 1;
        }   
        
        NSString *sizeStr = nil;
        if (totalSize <10000) {
            sizeStr = [NSString stringWithFormat:@"%f kb",(totalSize * 1.0/1024)];
        }else{
            sizeStr = [NSString stringWithFormat:@"%f mb",totalSize * 1.0/(1024 *1024)];
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isDebugMode) {
                    WSOLog(@"=========== Calculate cache size succeed:total fileCount:%ld & totalSize:%@",fileCount,sizeStr);
                }
                completionBlock(fileCount, totalSize);
            });
        }
    });

}


#pragma mark- Clear Cache

- (void)clearAllCacheWithCompletionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    dispatch_async(wso_cache_io_queue(), ^{
        
        NSError *removeCacheFolderError = nil;
        NSError *createCacheFolderError = nil;
        [_fileManager removeItemAtPath:_cacheBasePath error:&removeCacheFolderError];
        
        if (!removeCacheFolderError) {
            
            [_fileManager createDirectoryAtPath:_cacheBasePath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&createCacheFolderError];

            if (!createCacheFolderError) {
                
                if (_isDebugMode) {
                    WSOLog(@"=========== Clearing cache succeed");
                }
                if (completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES);
                        return;
                    });
                }
            }else{
                
                if (_isDebugMode) {
                    WSOLog(@"=========== Clearing cache error: Failed to create cache folder after removing it");
                }
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO);
                        return;
                    });
                }
            }
        }else{
           
            if (_isDebugMode) {
                WSOLog(@"=========== Clearing cache error: Failed to remove cache folder");
            }
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   completionBlock(NO);
                   return;
                });
           }
               
        };
    });
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    NSString *host_md5 =         [WSONetworkUtils generateMD5StringFromString: [NSString stringWithFormat:@"Host:%@",[WSONetworkConfig sharedConfig].baseUrl]];
    NSString *url_md5 =          [WSONetworkUtils generateMD5StringFromString: [NSString stringWithFormat:@"Url:%@",url]];
    NSString *requestIdentifer = [NSString stringWithFormat:@"%@_%@",host_md5,url_md5];
    
    [self clearCacheWithString:requestIdentifer completionBlock:completionBlock];
    
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl requestUrlStr:url method:@"POST" parameters:parameters];
    [self clearCacheWithString:requestIdentifer completionBlock:completionBlock];
    
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nonnull)parameters
          completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    NSString *requestIdentifer = [WSONetworkUtils generateRequestIdentiferWithBaseUrlStr:[WSONetworkConfig sharedConfig].baseUrl requestUrlStr:url method:method parameters:parameters];
    
    [self clearCacheWithString:requestIdentifer completionBlock:completionBlock];
    
}

- (void)clearCacheWithString:(NSString *)string completionBlock:(WSOClearCacheCompletionBlock _Nullable)completionBlock{

    
    NSMutableArray *deleteFileNamesArr = [[NSMutableArray alloc] initWithCapacity:2];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.cacheBasePath];
    
    for (NSString *fileName in enumerator){
        if ([fileName containsString:string]) {
            NSString *deleteFilePath = [self.cacheBasePath stringByAppendingPathComponent:fileName];
            [deleteFileNamesArr addObject:deleteFilePath];
        }
    }
    
    if ([deleteFileNamesArr count] > 0) {
        
        for (NSInteger index = 0; index < deleteFileNamesArr.count; index++) {
            
            dispatch_async(wso_cache_io_queue(), ^{
                
                [_fileManager removeItemAtPath:deleteFileNamesArr[index] error:nil];
                
                if (index == deleteFileNamesArr.count - 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) {
                            if (_isDebugMode) {
                                WSOLog(@"=========== Clearing cache succeed");
                            }
                            completionBlock(YES);
                            return;
                        }
                    });
                }
            });
            
        }
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                if (_isDebugMode) {
                    WSOLog(@"=========== Clearing cache error: there is no cache corresponding given info");
                }
                completionBlock(NO);
                return;
            }
        });
        
    }

}


#pragma mark- Cache Full Path

- (NSString *)cacheDataFilePathWithRequestIdentifer:(NSString *)requestIdentifer{
    
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@",self.cacheBasePath,requestIdentifer];
    return cacheFilePath;
}


- (NSString *)cacheInfoFilePathWithRequestIdentifer:(NSString *)requestIdentifer{
    
    NSString *cacheInfoFilePath = [NSString stringWithFormat:@"%@/%@",self.cacheBasePath,[requestIdentifer stringByAppendingString:@".cacheInfo"]];
    return cacheInfoFilePath;
}


#pragma mark- Setters & Getters

- (NSString *)cacheBasePath
{
    if (!_cacheBasePath) {
         _cacheBasePath = [WSONetworkUtils createBasePathWithFolderName:@"WSORequestCache"];
    }
    return _cacheBasePath;
}



@end
