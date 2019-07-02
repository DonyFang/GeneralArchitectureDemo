//
//  WSONetworkUtils.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSONetworkUtils.h"
#import <CommonCrypto/CommonDigest.h>

#define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD5_BLOCK_BYTES      64          /* block size in bytes */
#define CC_MD5_BLOCK_LONG       (CC_MD5_BLOCK_BYTES / sizeof(CC_LONG))


@implementation WSONetworkUtils


+ (NSString *)generateCompleteRequestUrlStrWithBaseUrlStr:(NSString *)baseUrlStr requestUrlStr:(NSString *)requestUrlStr{
    
    NSURL *requestUrl = [NSURL URLWithString:requestUrlStr];
    
    if (requestUrl && requestUrl.host && requestUrl.scheme) {
        return requestUrlStr;
    }
    
    NSURL *url = [NSURL URLWithString:baseUrlStr];
    
    if (baseUrlStr.length > 0 && ![baseUrlStr hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    return [NSURL URLWithString:requestUrlStr relativeToURL:url].absoluteString;
}



+ (NSString *)generateRequestIdentiferWithBaseUrlStr:(NSString *)baseUrlStr requestUrlStr:(NSString *)requestUrlStr method:(NSString *)method parameters:(id)parameters{
    
    NSString *host_md5 =         [self generateMD5StringFromString: [NSString stringWithFormat:@"Host:%@",baseUrlStr]];
    NSString *url_md5 =          [self generateMD5StringFromString: [NSString stringWithFormat:@"Url:%@",requestUrlStr]];
    NSString *method_md5 =       [self generateMD5StringFromString: [NSString stringWithFormat:@"Method:%@",method]];
    
    NSString *paramsStr = @"";
    NSString *parameters_md5 = @"";
    
    if (parameters) {
        paramsStr =        [self convertJsonStringFromDictionaryOrArray:parameters];
        parameters_md5 =   [self generateMD5StringFromString: [NSString stringWithFormat:@"Parameters:%@",paramsStr]];
    }
    
    NSString *requestIdentifer = [NSString stringWithFormat:@"%@_%@_%@_%@",host_md5,url_md5,method_md5,parameters_md5];
    
    return requestIdentifer;
}


+ (NSString *)generateMD5StringFromString:(NSString *)string {
    
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


+ (NSString *)convertJsonStringFromDictionaryOrArray:(id)parameter {
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return jsonStr;
}



+ (NSString *)createBasePathWithFolderName:(NSString *)folderName {
    
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:folderName];
    [self createDirectoryIfNeeded:path];
    return path;
}


+ (void)createDirectoryIfNeeded:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}


+ (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
}


+ (NSString *)createFullPathWithFolderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    NSString *fullPath = [folderPath stringByAppendingPathComponent:fileName];
    
    return fullPath;
}

+ (NSString *)appVersionStr{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


@end
