//
//  NSObject+HandleNUllString.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HandleNUllString)
- (BOOL)isBlankString:(id)string;
- (NSString *)handleString:(id)string;

@end
