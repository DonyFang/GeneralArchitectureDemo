//
//  HomeTableViewCell.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "HomeModel.h"
@interface HomeTableViewCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *content;

@property(nonatomic,strong)HomeModel *model;
@end
