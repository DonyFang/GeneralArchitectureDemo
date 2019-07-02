//
//  WWTLocationManger.h
//  Replenishment
//
//  Created by 尹星 on 2017/11/20.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWTLocation.h"
#import <UIKit/UIKit.h>
@interface WWTLocationManger : NSObject

+ (instancetype)shareInstance;

/**
 开始定位

 @param type type = 0表示查看定位权限，为1的时候表示开始定位，获取定位信息
 */
- (void)startUpdateLocationWithType:(WWTLocationType)type;

/**
 定位成功地址回掉

 @param block 定位地址回调block
 */
- (void)setAddressDetailsBlock:(LocationBlock)block;

@end
