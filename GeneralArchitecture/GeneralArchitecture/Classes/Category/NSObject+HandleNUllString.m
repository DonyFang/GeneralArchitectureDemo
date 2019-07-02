//
//  NSObject+HandleNUllString.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "NSObject+HandleNUllString.h"

@implementation NSObject (HandleNUllString)
//判断字符串是否为空
- (BOOL)isBlankString:(id)string {
    if (!string)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"(null)"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string length]==0)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}
- (NSString *)handleString:(id)string
{
    NSString *newStr = [NSString stringWithFormat:@"%@",string];
    NSString *backstring;
    if ([self isBlankString:newStr]) {
        backstring = @"";
    }else{
        backstring = newStr;
    }
    return backstring;
}
@end
