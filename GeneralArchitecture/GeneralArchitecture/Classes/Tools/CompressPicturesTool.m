//
//  CompressPicturesTool.m
//  MOffice
//
//  Created by 方冬冬 on 2018/4/13.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import "CompressPicturesTool.h"

@implementation CompressPicturesTool

/**
 压图片质量

 @param image image
 @return Data
 */
+ (NSData *)zipImageWithImage:(UIImage *)image imageType:(ImageQuality)imageType
{
    if (!image) {
        return nil;
    }//图片最大200KB
    
    CGFloat maxFileSize = 0;
    if (imageType == ImageQualityNormal) {
        maxFileSize = 100 * 1024;
    }
    if (imageType == ImageQualityStandard) {
        maxFileSize = 150 * 1024;
    }
    if (imageType == ImageQualityHigh) {
        maxFileSize = 200 * 1024;
    }
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    
    return compressedData;
}

+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size {
            UIImage *newImage = nil;
            CGSize imageSize = sourceImage.size;
            CGFloat width = imageSize.width;
            CGFloat height = imageSize.height;
            CGFloat targetWidth = size.width;
            CGFloat targetHeight = size.height;
            CGFloat scaleFactor = 0.0;
            CGFloat scaledWidth = targetWidth;
            CGFloat scaledHeight = targetHeight;
            CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
            if(CGSizeEqualToSize(imageSize, size) == NO){
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            }
            else{
            scaleFactor = heightFactor;
            }
            scaledWidth = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            if(widthFactor > heightFactor){

                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;

            }else if(widthFactor < heightFactor){

                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;

                }

                }
                UIGraphicsBeginImageContext(size);
                CGRect thumbnailRect = CGRectZero;
                thumbnailRect.origin = thumbnailPoint;
                thumbnailRect.size.width = scaledWidth;
                thumbnailRect.size.height = scaledHeight;
                [sourceImage drawInRect:thumbnailRect];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                if(newImage == nil){

                }
                UIGraphicsEndImageContext();
                return newImage;
}


/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);

    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));

    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }

    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();

    return newImage;

}

/**
 *将图片缩放到指定的CGSize大小
 * UIImage image 原始的图片
 * CGSize size 要缩放到的大小
 */
+(UIImage*)image:(UIImage *)image scaleToSize:(CGSize)size{

    // 得到图片上下文，指定绘制范围
    UIGraphicsBeginImageContext(size);

    // 将图片按照指定大小绘制
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];

    // 从当前图片上下文中导出图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // 当前图片上下文出栈
    UIGraphicsEndImageContext();

    // 返回新的改变大小后的图片
    return scaledImage;
}

+(NSData *)imageData:(UIImage *)myimage
{
    //普通--100       标准- 150   高清---200
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>1024 *1024) {
        if (data.length>10240*1024) {//10M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);//压缩之后1M~
        }else if (data.length>5120*1024){//5M~10M
            data=UIImageJPEGRepresentation(myimage, 0.2);//压缩之后1M~2M
        }else if (data.length>2048*1024){//2M~5M
            data=UIImageJPEGRepresentation(myimage, 0.5);//压缩之后1M~2.5M
        }
        //1M~2M不压缩
    }
    return data;
}



- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}
@end
