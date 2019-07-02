//
//  NSString+Extension.h
//  MOffice
//
//  Created by 方冬冬 on 2018/3/7.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Extension)
-(float)rw_getStringWidth:(float)aFontSize withSize:(CGSize)aSize;

/**
 *  Description
 *
 *  @param font 字符串的字体大小
 *  @param maxW <#maxW description#>
 *
 *  @return 返回的是字符串的
 */
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;

- (CGSize)sizeWithFont:(UIFont *)font;


/**
 *返回值是该字符串所占的大小(width, height)
 *font : 该字符串所用的字体(字体大小不一样,显示出来的面积也不同)
 *maxSize : 为限制改字体的最大宽和高(如果显示一行,则宽高都设置为MAXFLOAT, 如果显示为多行,只需将宽设置一个有限定长值,高设置为MAXFLOAT)
 */
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;


- (CGSize) sizeWithFont:(UIFont *)font maxH:(CGFloat)maxH;
+ (NSString *)sha1:(NSString *)input;

@end
