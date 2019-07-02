//
//  WSONetClient.m
//  Replenishment
//
//  Created by Sun Shijie on 2017/9/14.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import "WSONetClient.h"
#import "WSOAPIUrl.h"
#import <sys/utsname.h>

@interface WSONetClient()

@property (nonatomic, strong) WSOAPIClient *wsoClient;

@end

@implementation WSONetClient

+ (instancetype)shareClient
{
    static WSONetClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[[self class] alloc] init];
        _client.wsoClient = [WSOAPIClient sharedClient];
    });
    return _client;
}


////=========================== 旧接口 =============================//
//#pragma mark - 旧接口
//#pragma mark  登录
- (void)wso_loginWithUsername:(NSString *)username
                     password:(NSString *)password
                      success:(WSOSuccessBlock)successBlock
                        error:(WSOErrorBlock)errorBlock
                      failure:(WSOFailureBlock)failureBlock{
    //type:必填 1:移动作业
    NSDictionary *params = @{@"zhh":username,@"password":password,@"type":@"2"};
    [self.wsoClient sendPostRequest:LoginURL parameters:params ignoreToken:YES success:^(id response, NSUInteger code, NSString *message) {
        if(successBlock){
            successBlock(response,code,message);
        }
    } error:^(NSError *error, NSString *message) {
        if (errorBlock) {
            errorBlock(error,message);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (void)ga_getHomeDataFromeServerWith:(NSString *)pageSize
                              success:(WSOSuccessBlock)successBlock
                                error:(WSOErrorBlock)errorBlock
                              failure:(WSOFailureBlock)failureBlock{
    


}

//判断字符串是否为空
- (BOOL) isBlankString:(id)string {
    if (!string)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"(null)"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string length]==0)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}

@end
