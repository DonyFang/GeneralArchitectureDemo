//
//  WSONetworkUtils.h
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

/* =============================
 *
 * WSONetworkUtils
 *
 * WSONetworkUtils is in charge of some operation of string or app information
 *
 * =============================
 */

@interface WSONetworkUtils : NSObject


/**
 *  This method is used to return app version
 *
 *  @return app version string
 */
+ (NSString *)appVersionStr;


/**
 *  This method is used to generate complete request url
 *
 *  @param baseUrlStr                   base url
 *  @param requestUrlStr                request url
 *
 *  @return the complete request url
 */
+ (NSString *)generateCompleteRequestUrlStrWithBaseUrlStr:(NSString *)baseUrlStr
                                            requestUrlStr:(NSString *)requestUrlStr;


/**
 *  This method is used to unique identifer of a specific request
 *
 *  @param baseUrlStr                   base url
 *  @param requestUrlStr                request url
 *  @param method                       request method
 *  @param parameters                   parameters (can be nil)
 *
 *  @return the complete request url
 */
+ (NSString *)generateRequestIdentiferWithBaseUrlStr:(NSString *)baseUrlStr
                                       requestUrlStr:(NSString *)requestUrlStr
                                              method:(NSString *)method
                                          parameters:(id)parameters;

/**
 *  This method is used to generate the md5 string of given string
 *
 *  @param string                       original string
 *
 *  @return the transformed md5 string
 */
+ (NSString *)generateMD5StringFromString:(NSString *)string;



/**
 *  This method is used to folder of a given folder name
 *
 *  @param folderName                   folder name
 *
 *  @return the full path of the new folder
 */
+ (NSString *)createBasePathWithFolderName:(NSString *)folderName;



/**
 *  This method is used to generate the full path of a file by given folder path and file name
 *
 *  @return the full path of a file
 */
+ (NSString *)createFullPathWithFolderPath:(NSString *)folderPath
                                  fileName:(NSString *)name;

@end

