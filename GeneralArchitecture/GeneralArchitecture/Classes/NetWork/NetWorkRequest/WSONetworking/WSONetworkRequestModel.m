//
//  WSONetworkRequestModel.m
//  WSONetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "WSONetworkRequestModel.h"
#import "WSONetworkConfig.h"


@interface WSONetworkRequestModel()

@end


@implementation WSONetworkRequestModel


- (void)clearAllBlocks{
    
    _uploadProgressBlock = nil;
    _downloadProgressBlock = nil;
    _successBlock = nil;
    _failureBlock = nil;
    
}


- (NSString *)description{
    
    if ([WSONetworkConfig sharedConfig].debugMode) {
        
         return [NSString stringWithFormat:@"%@:\n{\n   url:%@\n   method:%@\n   parameters:%@\n   loadCache:%@\n   cacheDuration:%@ \n   requestIdentifer:%@\n   task:%@\n}",[self class] ,_requestUrl,_method,_parameters,[NSNumber numberWithBool:_loadCache],[NSNumber numberWithInteger:_cacheDuration],_requestIdentifer,_dataTask];
    }else{
        
         return [NSString stringWithFormat:@"%@:\n{\n   url:%@\n   method:%@\n   parameters:%@\n   loadCache:%@\n   cacheDuration:%@ \n   task:%@\n}",[self class] ,_requestUrl,_method,_parameters,[NSNumber numberWithBool:_loadCache],[NSNumber numberWithInteger:_cacheDuration],_dataTask];
    }
}

@end
