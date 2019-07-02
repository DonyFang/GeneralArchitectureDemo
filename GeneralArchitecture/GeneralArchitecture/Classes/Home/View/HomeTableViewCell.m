//
//  HomeTableViewCell.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}
- (void)setModel:(HomeModel *)model{
    _model = model;
    self.title.text = [self handleString:model.name];
    self.content.text = [self handleString:model.motto];
}

@end
