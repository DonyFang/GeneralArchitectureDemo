//
//  WWTLocation.h
//  Replenishment
//
//  Created by 尹星 on 2017/11/20.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WWTLocationType) {
    WWTTestMobilePositioningFunction = 0,//查看定位权限
    WWTStartUpdateLocation,//开始定位，返回定位信息
};

typedef void (^LocationBlock)(NSDictionary *addressDictionary, CGFloat longitude, CGFloat latitude);

@interface WWTLocation : NSObject

@property (nonatomic, copy) LocationBlock             locationBlock;

- (void)startUpdateLocationWithType:(WWTLocationType)type;

@end
