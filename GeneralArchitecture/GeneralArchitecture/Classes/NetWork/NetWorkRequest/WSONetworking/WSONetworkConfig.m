//
//  WSONetworkConfig.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSONetworkConfig.h"

@implementation WSONetworkConfig

+ (WSONetworkConfig *)sharedConfig {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
