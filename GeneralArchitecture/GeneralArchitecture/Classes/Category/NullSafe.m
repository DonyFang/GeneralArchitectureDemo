//
//  NullSafe.m
//
//  Version 2.0
//
//  Created by Nick Lockwood on 19/12/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/NullSafe
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>


#ifndef NULLSAFE_ENABLED
#define NULLSAFE_ENABLED 1
#endif


#pragma clang diagnostic ignored "-Wgnu-conditional-omitted-operand"


@implementation NSNull (NullSafe)

#if NULLSAFE_ENABLED
/*
 在一个函数找不到时，Objective-C提供了三种方式去补救：
 调用resolveInstanceMethod给个机会让类添加这个实现这个函数
 调用forwardingTargetForSelector让别的对象去执行这个函数
 调用methodSignatureForSelector（函数符号制造器）和forwardInvocation（函数执行器）灵活的将目标函数以其他形式执行。
 如果都不中，调用doesNotRecognizeSelector抛出异常。
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    //如果没有使用Fast Forwarding来消息转发，最后只有使用Normal Forwarding来进行消息转发。它首先调用methodSignatureForSelector:方法来获取函数的参数和返回值，如果返回为nil，程序会 crash 掉，并抛出unrecognized selector sent to instance异常信息。如果返回一个函数签名，系统就会创建一个NSInvocation对象并调用-forwardInvocation:方法。

    //look up method signature。函数符号制造器
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature)
    {
        for (Class someClass in @[
            [NSMutableArray class],
            [NSMutableDictionary class],
            [NSMutableString class],
            [NSNumber class],
            [NSDate class],
            [NSData class]
        ])
        {
            @try
            {
                if ([someClass instancesRespondToSelector:selector])
                {
                    signature = [someClass instanceMethodSignatureForSelector:selector];
                    break;
                }
            }
            @catch (__unused NSException *unused) {}
        }
    }
    return signature;
}
//消息转发
- (void)forwardInvocation:(NSInvocation *)invocation//forwardInvocation（函数执行器）灵活的将目标函数以其他形式执行。
{   //把空null  转化为nil 将其执行函数的对象变为nil去执行
    invocation.target = nil;
    [invocation invoke];
}

#endif

@end
