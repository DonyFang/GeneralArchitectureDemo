//
//  BaseViewModel.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseViewModel.h"

@implementation BaseViewModel
-(instancetype)init{
    self = [super init];
    if (self) {
        self.arrayData = [NSMutableArray array];

    }
    return self;
}

#pragma 接收传过来的block
-(void)setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock
{
    self.returnBlock = returnBlock;
    self.errorBlock = errorBlock;
    self.failureBlock = failureBlock;
}
@end
