//
//  GetWordColor.h
//  MatchNet
//
//  Created by lyywhg on 14-7-24.
//  Copyright (c) 2014年 JSLtd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetWordColor : NSObject

+(UIColor *)colorWithHexString:(NSString *)stringToConvert;
+(UIColor*)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

@end
