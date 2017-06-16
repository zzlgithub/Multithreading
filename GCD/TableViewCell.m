//
//  TableViewCell.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/15.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  
}
- (void)setLable:(UILabel *)lable{
    _lable = lable;
    _lable.text = lable.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
