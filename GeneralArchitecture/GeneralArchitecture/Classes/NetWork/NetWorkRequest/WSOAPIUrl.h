//
//  WSOAPIUrl.h
//  Replenishment
//
//  Created by Sun Shijie on 2017/9/14.
//  Copyright © 2017年 ruwang. All rights reserved.
//  

#ifndef WSOAPIUrl_h
#define WSOAPIUrl_h
//===============================Moffice=========================================
//https://10.88.40.54:28299
//4--5  http://10.88.40.192:29306
//#define BASE_URL @"https://192.168.80.15:28299/APPAGENT/"
//https://192.168.80.11:28100/APPAGENT/     开发环境APPAGENT服务192.168.80.19
//#define BASE_URL @"https://192.168.80.19:28100/APPAGENT/"
//#define BASE_URL @"https://192.168.80.11:28100/APPAGENT/"
//https://192.168.80.11:28100/APPAGENT/
#define SAVEDEFAULTS(value,key) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];
#define GETDEFAULTS(key) [[[NSUserDefaults standardUserDefaults] objectForKey:key] stringByReplacingOccurrencesOfString:@" " withString:@""];
#define BaseI_P [[[NSUserDefaults standardUserDefaults] objectForKey:@"BaseI_P"] stringByReplacingOccurrencesOfString:@" " withString:@""]
        
#define Base_port [[[NSUserDefaults standardUserDefaults] objectForKey:@"Base_port"] stringByReplacingOccurrencesOfString:@" " withString:@""]
#if TARGET_ENVIROMENT == 1
//#define BaseIPNUM   @"192.168.80.11"
//#define BasePortNUm @"28100"
//#define BaseIPNUM   @"10.88.40.228"//228
//#define BasePortNUm @"28100"
#define BaseIPNUM   @"10.88.40.127"//228
#define BasePortNUm @"28299"
#else
#define BaseIPNUM   @"10.88.40.127"
#define BasePortNUm @"28299"
#endif

                                            //记住修改了https ->http
//#define BASE_URL [NSString stringWithFormat:@"https://%@:%@/APPAGENT/",BaseI_P,Base_port]
#define BASE_URL [NSString stringWithFormat:@"https://%@:%@/APPAGENT/",BaseI_P,Base_port]

#define LoginURL @" "


#endif /* WSOAPIUrl_h */
