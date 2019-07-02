//
//  YLButton.h
//  YLButton
//
//  Created by HelloYeah on 2016/11/24.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLButton : UIButton

@property (nonatomic,assign) CGRect titleRect;
@property (nonatomic,assign) CGRect imageRect;

//是否扩大点击范围
@property(nonatomic,assign)BOOL isEnlarge;

@end
