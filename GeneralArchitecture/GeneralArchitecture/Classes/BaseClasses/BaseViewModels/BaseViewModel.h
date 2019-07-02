//
//  BaseViewModel.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

typedef void (^ReturnValueBlock) (id returnValue);
typedef void (^ErrorCodeBlock) (id errorCode,NSString *message);
typedef void (^FailureBlock)(void);
typedef void (^NetWorkBlock)(BOOL netConnetState);


@interface BaseViewModel : NSObject
@property (strong, nonatomic) ReturnValueBlock returnBlock;
@property (strong, nonatomic) ErrorCodeBlock errorBlock;
@property (strong, nonatomic) FailureBlock failureBlock;

@property (nonatomic,strong) NSDictionary *dicData;
@property (nonatomic,strong) NSMutableArray *arrayData;
@property (nonatomic, strong) BaseModel *model;
// 传入交互的Block块
-(void)setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock;
@end
