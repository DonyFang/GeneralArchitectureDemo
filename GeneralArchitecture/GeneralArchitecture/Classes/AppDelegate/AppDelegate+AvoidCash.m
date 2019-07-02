//
//  AppDelegate+AvoidCash.m
//  MOffice
//
//  Created by 方冬冬 on 2019/3/13.
//  Copyright © 2019年 ChinaSoft. All rights reserved.
//

#import "AppDelegate+AvoidCash.h"
#import <AvoidCrash.h>
#import <sys/utsname.h>
@implementation AppDelegate (AvoidCash)
- (void)initWithCrashTool{
//#if DEBUG
//#else
    [AvoidCrash becomeEffective];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
//#endif

}
- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    NSLog(@"%@",note.userInfo);
    //错误名称
    NSString *errorName = [NSString stringWithFormat:@"%@",note.userInfo[@"errorName"]];
    //错误地方
    NSString *errorPlace = [NSString stringWithFormat:@"%@",note.userInfo[@"errorPlace"]];
    //错误原因
    NSString *errorReason = [NSString stringWithFormat:@"%@",note.userInfo[@"errorReason"]];
    //异常
    NSString *exception = [NSString stringWithFormat:@"%@",note.userInfo[@"exception"]];
    NSString *sysVersions = [[UIDevice currentDevice] systemVersion]; //获取系统版本 例如：9.2
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"]; // 获取App的版本
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"]; // 获取App的名称
    //手机UUId 类imi序列号
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //获取手机的型号
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    NSString *phoneModel = [self currentModel:model];
    //1.手机系统版本：11.0
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString *exceptionInfo =
    [NSString stringWithFormat:@"sysVersions:%@\n appVersion:%@\n appNamek:%@\n phoneModel:%@\n errorName:%@\n errorPlace:%@\n errorReason:%@\n exception:%@\n",sysVersions,appVersion,appName,phoneModel,errorName,errorPlace,errorReason,exception];
    //当前时间
    NSString *currentTime = [self getCurrentTimes];
    //ime 手机串号后7位
    NSString *randomNum = [identifierForVendor substringFromIndex:identifierForVendor.length-6];
    //App名称_版本号_日期_时间_7位随机码.txt
    [self saveCrashLog:exceptionInfo];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@.txt",appName,appVersion,currentTime,randomNum];
    NSData *fileData = [self readCrashLog];
//    [[WSONetClient shareClient] m_UploadCrashLogWithappType:@"21" appVersion:appVersion phoneModel:phoneModel imiNo:identifierForVendor logName:fileName aFile:@"aFile" fileData:fileData phoneVersion:phoneVersion progress:^(NSProgress *uploadProgress) {
//    } success:^(id response, NSUInteger code, NSString *message) {
//        //如果上传日志成功 那么删除本地保存的崩溃日志
//        [self deleteCrashLog];
//    } failure:^(NSError *error) {
//
//    }];

}
- (void)saveCrashLog:(NSString *)crashLog
{   
    NSArray *array1 =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documents = [array1 lastObject];
    NSString *documentPath = [documents stringByAppendingPathComponent:@"crashLog.txt"];
    // 准备好要存到本地的数组
    NSString *log= crashLog;
    //将数组存入到指定的本地文件
    [log writeToFile:documentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}   

- (void)deleteCrashLog{
    /*
    在通过文件的名字获取到文件路径之后，通过NSFileManage来删除某个路径的文件
    */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docuPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [docuPathArr lastObject];
    NSString *documentPath = [documents stringByAppendingPathComponent:@"crashLog.txt"];
    BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
    if (blHave) {
        BOOL blDele= [fileManager removeItemAtPath:documentPath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }

}
- (NSData *)readCrashLog
{
    NSArray *array1 =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documents = [array1 lastObject];
    NSString *documentPath = [documents stringByAppendingPathComponent:@"crashLog.txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:documentPath];
    return fileData;
}
- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd_HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}
- (NSString *)currentModel:(NSString *)phoneModel {
    if ([phoneModel isEqualToString:@"iPhone3,1"] ||
        [phoneModel isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
    if ([phoneModel isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    if ([phoneModel isEqualToString:@"iPhone5,1"] ||
        [phoneModel isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([phoneModel isEqualToString:@"iPhone5,3"] ||
        [phoneModel isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([phoneModel isEqualToString:@"iPhone6,1"] ||
        [phoneModel isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    if ([phoneModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([phoneModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([phoneModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([phoneModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([phoneModel isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([phoneModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([phoneModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,1"] ||
        [phoneModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([phoneModel isEqualToString:@"iPhone10,2"] ||
        [phoneModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,3"] ||
        [phoneModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([phoneModel isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([phoneModel isEqualToString:@"iPad2,1"] ||
        [phoneModel isEqualToString:@"iPad2,2"] ||
        [phoneModel isEqualToString:@"iPad2,3"] ||
        [phoneModel isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([phoneModel isEqualToString:@"iPad3,1"] ||
        [phoneModel isEqualToString:@"iPad3,2"] ||
        [phoneModel isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([phoneModel isEqualToString:@"iPad3,4"] ||
        [phoneModel isEqualToString:@"iPad3,5"] ||
        [phoneModel isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([phoneModel isEqualToString:@"iPad4,1"] ||
        [phoneModel isEqualToString:@"iPad4,2"] ||
        [phoneModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([phoneModel isEqualToString:@"iPad5,3"] ||
        [phoneModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([phoneModel isEqualToString:@"iPad6,3"] ||
        [phoneModel isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([phoneModel isEqualToString:@"iPad6,7"] ||
        [phoneModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad6,11"] ||
        [phoneModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([phoneModel isEqualToString:@"iPad7,1"] ||
        [phoneModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([phoneModel isEqualToString:@"iPad7,3"] ||
        [phoneModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    if ([phoneModel isEqualToString:@"iPad2,5"] ||
        [phoneModel isEqualToString:@"iPad2,6"] ||
        [phoneModel isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([phoneModel isEqualToString:@"iPad4,4"] ||
        [phoneModel isEqualToString:@"iPad4,5"] ||
        [phoneModel isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([phoneModel isEqualToString:@"iPad4,7"] ||
        [phoneModel isEqualToString:@"iPad4,8"] ||
        [phoneModel isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([phoneModel isEqualToString:@"iPad5,1"] ||
        [phoneModel isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    if ([phoneModel isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([phoneModel isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([phoneModel isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([phoneModel isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([phoneModel isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([phoneModel isEqualToString:@"iPod7,1"]) return @"iTouch6";
    if ([phoneModel isEqualToString:@"i386"] || [phoneModel isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    return @"Unknown";
}
//获取崩溃日志的方法
//NSSetUncaughtExceptionHandler(&caughtExceptionHandler);
//void caughtExceptionHandler(NSException *exception){
//    /**
//     *  获取异常崩溃信息
//     */
//    NSArray *callStack = [exception callStackSymbols];//得到当前调用栈信息
//    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
//    NSString *name = [exception name];//异常类型
//    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\\nname:%@\\nreason:\\n%@\\ncallStackSymbols:\\n%@",name,reason,[callStack componentsJoinedByString:@"\\n"]];
//    //把异常崩溃信息发送至开发者邮件
//    NSMutableString *mailUrl = [NSMutableString string];
//    [mailUrl appendString:@"mailto:xxx@qq.com"];
//    [mailUrl appendString:@"?subject=程序异常崩溃信息，请配合发送异常报告，谢谢合作！"];
//    [mailUrl appendFormat:@"&body=%@", content];
//    // 打开地址
//    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
//}
@end
