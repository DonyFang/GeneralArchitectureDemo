//
//  BaseTableViewCell.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
+ (instancetype)cellWithTableView:(UITableView *)tableview{
    NSString *className = NSStringFromClass([self class]);
    NSString *cellID = className;
    Class TableViewCell = NSClassFromString(className);
    BaseTableViewCell *cell = [[TableViewCell alloc] init];
    cell = [tableview dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = (BaseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] lastObject];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}
@end
