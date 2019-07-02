//
//  HomeViewModel.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "HomeViewModel.h"
#import "HomeModel.h"
@interface  HomeViewModel()
@end
@implementation HomeViewModel
- (void)ga_getHomeDataFromeServerWith:(NSString *)pageSize
{
    NSArray *data = @[@{@"name":@"别林斯基", @"motto":@"土地是以它的肥沃和收获而被估价的；才能也是土地，不过它生产的不是粮食，而是真理。如果只能滋生瞑想和幻想的话，即使再大的才能也只是砂地或盐池，那上面连小草也长不出来的。"},
                      @{@"name":@"蒙田", @"motto":@"我需要三件东西：爱情友谊和图书。然而这三者之间何其相通！炽热的爱情可以充实图书的内容，图书又是人们最忠实的朋友"},
                      @{@"name":@"德奥弗拉斯多", @"motto":@"时间是一切财富中最宝贵的财富。"}];
    [self.arrayData removeAllObjects];
    NSArray *dataArry = data;
    NSError *error = nil;
    [self.arrayData addObjectsFromArray:[HomeModel arrayOfModelsFromDictionaries:dataArry error:&error]];
    if (error) {
        if (self.errorBlock) {
            self.errorBlock(0,error.description);
        }
        return;
    }   
    if (self.returnBlock) {
        self.returnBlock(dataArry);
    }
}
@end
