//
//  WWTLocationManger.m
//  Replenishment
//
//  Created by 尹星 on 2017/11/20.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import "WWTLocationManger.h"

@interface WWTLocationManger ()

@property (nonatomic, strong) WWTLocation             *location;

@property (nonatomic, copy) LocationBlock             addressDetailsblock;

@end

@implementation WWTLocationManger

+ (instancetype)shareInstance
{
    static WWTLocationManger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)startUpdateLocationWithType:(WWTLocationType)type
{
    __weak typeof(self) weak_self = self;
    self.location.locationBlock = ^(NSDictionary *addressDictionary, CGFloat longitude, CGFloat latitude) {
        if (weak_self.addressDetailsblock) {
            weak_self.addressDetailsblock(addressDictionary, longitude, latitude);
        }
    };
    [self.location startUpdateLocationWithType:type];
}

- (void)setAddressDetailsBlock:(LocationBlock)block
{
    self.addressDetailsblock = block;
}

#pragma mark - 懒加载
- (WWTLocation *)location
{
    if (!_location) {
        _location = [[WWTLocation alloc] init];
    }
    return _location;
}

@end
