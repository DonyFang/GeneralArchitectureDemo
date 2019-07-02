//
//  UIView+Frame.h
//  codeSnip
//
//  Created by reddick on 15/9/1.
//  Copyright (c) 2015年 reddick. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenBounds [UIScreen mainScreen].bounds

@interface UIView (Frame)
@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;
@property (assign, nonatomic) CGFloat    left;
@property (assign, nonatomic) CGFloat    right;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, readonly) CGFloat bottomY;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGSize size;

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width;

- (void)toCircleView;

- (void)removeAllSubviews;
@end
