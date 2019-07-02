//
//  FDDCameraManager.h
//  MOffice
//
//  Created by 方冬冬 on 2019/4/29.
//  Copyright © 2019年 ChinaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
//定义枚举类型
typedef enum OperationType {
    Camera  = 0,//相机
    PhotoAlbum//相册
} OperationType;
typedef void (^FinishedBlock)(id object);
@interface FDDCameraManager : NSObject
@property (nonatomic , copy)FinishedBlock Finishedblock;
+(instancetype)sharedManager;
- (void)startPhotoWithOperationType:(OperationType)type;
@end
