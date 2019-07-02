//
//  WSONetworkRequestModel.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef DEBUG
#define WSOLog(...) NSLog(@"%s line number:%d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define WSOLog(...)
#endif


/**
 *  callback
 */
typedef void(^WSO2SuccessBlock)(id response);
typedef void(^WSO2FailureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef void(^WSO2UploadProgressBlock)(NSProgress *uploadProgress);

typedef void(^WSO2UploadProgressBlock)(NSProgress *uploadProgress);
typedef void(^WSO2DownloadProgressBlock)(NSProgress *uploadProgress);


/**
 *  HTTP Request method
 */
typedef NS_ENUM(NSInteger, WSORequestMethod) {
    WSORequestMethodGET = 0,
    WSORequestMethodPOST,
    WSORequestMethodPUT,
    
};


@interface WSONetworkRequestModel : NSObject


@property (nonatomic, readwrite, copy)   NSString *requestUrl;
@property (nonatomic, readwrite, copy)   NSString *method;
@property (nonatomic, readwrite, strong) id parameters;
@property (nonatomic, readwrite, assign) BOOL loadCache;
@property (nonatomic, readwrite, assign) NSTimeInterval cacheDuration;
@property (nonatomic, readwrite, copy)   NSString *requestIdentifer;

@property (nonatomic, readwrite, copy)   NSArray<UIImage *> *uploadImages;
//上传的单张图片数据
@property(nonatomic,strong)UIImage *uploadImage;
//上传的单张图片名称
@property (nonatomic, copy) NSString *uploadImageName;


@property (nonatomic, readwrite, copy)   NSArray *uploadImageInfos;//每个元素是一个字典，key是name,value是UIImage
@property (nonatomic, readwrite, copy)   NSString *imagesIdentifer;
@property (nonatomic, readwrite, copy)   NSString *mimeType;
@property (nonatomic, readwrite, assign) float imageCompressRatio;

@property (nonatomic, readwrite, copy)   WSO2UploadProgressBlock uploadProgressBlock;
@property (nonatomic, readwrite, copy)   WSO2DownloadProgressBlock downloadProgressBlock;
@property (nonatomic, readwrite, copy)   WSO2SuccessBlock successBlock;
@property (nonatomic, readwrite, copy)   WSO2FailureBlock failureBlock;

@property(nonatomic,strong)NSString *imageName;
@property (nonatomic, readwrite, strong) id responseObject;
@property (nonatomic, readwrite, strong) NSData *responseData;
@property (nonatomic, readwrite, strong) NSURLSessionDataTask *dataTask;
//文件名
@property (nonatomic, copy) NSString *fileName;
//文件数据
@property(nonatomic,strong)NSData *fileData;

- (void)clearAllBlocks;

@end
