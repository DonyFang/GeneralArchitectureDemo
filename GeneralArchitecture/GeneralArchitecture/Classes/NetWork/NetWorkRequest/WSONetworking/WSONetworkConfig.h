//
//  WSONetworkConfig.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

/* =============================
 *
 * WSONetworkConfig
 *
 * WSONetworkConfig is in charge of the configuration of all related network requests 
 *
 * =============================
 */

@interface WSONetworkConfig : NSObject

// Base url of requests
@property (nonatomic, strong) NSString *baseUrl;

// Default parameters of all POST requests,can be nil
@property (nonatomic, strong) NSDictionary *defailtParameters;

// If debugMode is set to be YES, then print all detail log
@property (nonatomic, assign) BOOL debugMode;

/**
 *  WSONetworkConfig Singleton
 *
 *  @return sharedConfig singleton instance
 */
+ (WSONetworkConfig *)sharedConfig;

@end
