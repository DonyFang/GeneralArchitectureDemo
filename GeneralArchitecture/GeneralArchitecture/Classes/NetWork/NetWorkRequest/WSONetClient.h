//
//  WSONetClient.h
//  Replenishment
//
//  Created by Sun Shijie on 2017/9/14.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSOAPIClient.h"

@interface WSONetClient : NSObject

+ (instancetype)shareClient;

//=========================== 旧接口 =============================//

/// 登录
- (void)wso_loginWithUsername:(NSString *)username
                     password:(NSString *)password
                      success:(WSOSuccessBlock)successBlock
                        error:(WSOErrorBlock)errorBlock
                      failure:(WSOFailureBlock)failureBlock;

- (void)ga_getHomeDataFromeServerWith:(NSString *)pageSize
                              success:(WSOSuccessBlock)successBlock
                                error:(WSOErrorBlock)errorBlock
                              failure:(WSOFailureBlock)failureBlock;
@end
