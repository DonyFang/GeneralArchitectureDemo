//
//  HomeView.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeView;
@class HomeModel;
@protocol HomeViewDelegate<NSObject>
@required
- (void)home:(HomeView *)view requestHomeListWithPage:(NSInteger)page;
@end
@interface HomeView : UIView
@property(nonatomic,weak)id <HomeViewDelegate>delegate;


- (void)requestHomeListSuccessWithArray:(NSArray<HomeModel *> *)array;

- (void)requestHomeListFailed;
@end
