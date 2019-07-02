//
//  NSString+Extension.m
//  MOffice
//
//  Created by 方冬冬 on 2018/3/7.
//  Copyright © 2018年 ChinaSoft. All rights reserved.
//

#import "NSString+Extension.h"
 #import <CommonCrypto/CommonDigest.h>
@implementation NSString (Extension)
-(float)rw_getStringWidth:(float)aFontSize withSize:(CGSize)aSize{
    return CGRectGetWidth([self boundingRectWithSize:aSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize]} context:nil]);
    
}


/**
 *  返回字符串所需大小
 */
- (CGSize) sizeWithFont:(UIFont *)font
{
    return [self sizeWithFont:font maxW:MAXFLOAT];
}

/**
 *  返回字符串所需大小 指定宽度,返回高度
 */
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    return [self boundingRectWithSize:CGSizeMake(maxW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/**
 *  返回字符串所需大小 指定高度,返回宽度度
 */
- (CGSize) sizeWithFont:(UIFont *)font maxH:(CGFloat)maxH
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, maxH) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

//返回字符串所占用的尺寸
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
//- (NSString *)sha1:(NSInteger)salt
//{
//
//    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
//
//    NSData *data = [NSData dataWithBytes:cstr length:self.length];
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
//    NSMutableString *outputStr = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
//        [outputStr appendFormat:@"%02x%li", digest[i] & 0xff,(long)salt];
//    }
//
//    return outputStr;
//
//}
//sha1加密方式
//- (NSString *)sha1:(NSString *)input
//{
//    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"cstr==%s",cstr);
//    NSData *data = [NSData dataWithBytes:cstr length:input.length];
////    uint8_t
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%0x", digest[i] & 1115];
//        NSLog(@"digest[i]===%hhu digest[i] & 1115=%d",digest[i],digest[i] & 1115);
//
//    }
//    return output;
//}

+ (NSString *)sha1:(NSString *)input
{
    NSString *saltStr = @"盐值";
    int saltNum = [saltStr intValue];
    //const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [NSData dataWithBytes:cstr length:input.length];
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%0x", digest[i] & saltNum];
//        NSLog(@"digest[i]===%hhu digest[i] & 1115=%d",digest[i],digest[i] & 1115);
    }
    return output;
}

- (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];

    NSString *jsonString = @"";

    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符

    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return jsonString;
}
// 字典转json字符串方法

-(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        NSLog(@"%@",error);

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}

@end
