//
//  GlobalAppearance.h
//  LingTouNiaoZF
//
//  Created by LiuFeifei on 16/10/24.
//  Copyright © 2016年 LiuJie. All rights reserved.
//

#ifndef GlobalAppearance_h
#define GlobalAppearance_h

#pragma mark - 字体

#define kFont(size)  [CustomFont heiti:size]
#define kStringSize(string, fontSize) [string sizeWithAttributes:@{NSFontAttributeName : kFont(fontSize)}]

#pragma mark 常用字体大小

#define kFont18 kFont(18)
#define kFont16 kFont(16)
#define kFont14 kFont(14)
#define kFont12 kFont(12)
#define kFont11 kFont(11)

#pragma mark - 颜色

#define kHexColor(hexColor) [UIColor colorWithHex:hexColor]
#define kHexStringColor(hexStringColor) [UIColor colorWithHexString:hexStringColor]
#define kRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define kRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]

#pragma mark 常用颜色

#define kBrightColorFF6600 kHexColor(0xff6600)
#define kBrightColorFFCE00 kHexColor(0xffce00)
#define kBrightColor288BFF kHexColor(0x288bff)
#define kBrightColorFF0000 kHexColor(0xff0000)
#define kDarkColor333333 kHexColor(0x333333)
#define kDarkColor666666 kHexColor(0x666666)
#define kDarkColor999999 kHexColor(0x999999)
#define kDarkColor878787 kHexColor(0x878787)
#define kDarkColorADADAD kHexColor(0xadadad)

#define kNavigationBarColor [UIColor whiteColor]
#define kLineColorD8D8D8 kHexColor(0xd8d8d8)


//字体大小一栏
#define FONT8                                        [UIFont systemFontOfSize:8.0f]
#define FONT9                                        [UIFont systemFontOfSize:9.0f]
#define FONT10                                       [UIFont systemFontOfSize:10.0f]
#define FONT11                                       [UIFont systemFontOfSize:11.0f]
#define FONT12                                       [UIFont systemFontOfSize:12.0f]
#define FONT13                                       [UIFont systemFontOfSize:13.0f]
#define FONT14                                       [UIFont systemFontOfSize:14.0f]
#define FONT15                                       [UIFont systemFontOfSize:15.0f]
#define FONT16                                       [UIFont systemFontOfSize:16.0f]
#define FONT17                                       [UIFont systemFontOfSize:17.0f]
#define FONT18                                       [UIFont systemFontOfSize:18.0f]
#define FONT19                                       [UIFont systemFontOfSize:19.0f]
#define FONT20                                       [UIFont systemFontOfSize:20.0f]
#define FONT21                                       [UIFont systemFontOfSize:21.0f]
#define FONT22                                       [UIFont systemFontOfSize:22.0f]
#define FONT23                                       [UIFont systemFontOfSize:23.0f]
#define FONT26                                       [UIFont systemFontOfSize:26.0f]
#define FONT30                                       [UIFont systemFontOfSize:30.0f]
#define FONT31                                       [UIFont systemFontOfSize:31.0f]
#define FONT32                                       [UIFont systemFontOfSize:32.0f]
#define FONT33                                       [UIFont systemFontOfSize:33.0f]
#define FONT34                                       [UIFont systemFontOfSize:34.0f]
#define FONT35                                       [UIFont systemFontOfSize:35.0f]
#define FONT36                                       [UIFont systemFontOfSize:36.0f]

//屏幕宽高
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//获取APP版本号
#define FDCurrentVersion [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]
//颜色
#define RGBCOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
//设置 view 圆角和边框
#define FDViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

#endif /* GlobalAppearance_h */
