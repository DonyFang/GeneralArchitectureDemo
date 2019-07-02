//
//  BaseTableView.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        /** 去除tableview 右侧滚动条 */
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}
@end
