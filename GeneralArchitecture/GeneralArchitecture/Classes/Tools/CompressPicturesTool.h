//
//  CompressPicturesTool.h
//  MOffice
//
//  Created by 方冬冬 on 2018/4/13.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ImageQuality) {
    ImageQualityNormal,
    ImageQualityStandard,
    ImageQualityHigh,
};
@interface CompressPicturesTool : NSObject
//压缩图片。保证清晰度的同时 压缩文件到指定的大小
+ (NSData *)zipImageWithImage:(UIImage *)image imageType:(ImageQuality)imageType;

@property (nonatomic,assign) ImageQuality   imageType;
@end
