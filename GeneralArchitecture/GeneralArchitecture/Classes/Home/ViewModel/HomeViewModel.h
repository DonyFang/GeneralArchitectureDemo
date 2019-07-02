//
//  HomeViewModel.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseViewModel.h"

@interface HomeViewModel : BaseViewModel
- (void)ga_getHomeDataFromeServerWith:(NSString *)pageSize;
@end
