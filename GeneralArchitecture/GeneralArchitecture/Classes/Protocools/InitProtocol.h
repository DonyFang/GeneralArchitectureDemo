//
//  InitProtocol.h
//  MOffice
//
//  Created by 方冬冬 on 2018/2/5.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InitProtocol <NSObject>
@optional
/**
 *初始化变量
 */
- (void)rw_initVaraies;
/**
 *初始化视图控件等
 */
- (void)rw_initViews;
/**
 *网络请求加载
 */
- (void)rw_initNetData;

@end
