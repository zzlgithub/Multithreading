//
//  CustomOperationCell.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/17.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "CustomOperationCell.h"

@interface CustomOperationCell ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *no;
@end

@implementation CustomOperationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setGirl:(BeautyGirl *)girl{
    _girl = girl;
    self.name.text = girl.name;
    self.no.text = girl.no;

}

- (void)setImageGirl:(UIImageView *)imageGirl{
    _imageGirl = imageGirl;
    _imageGirl.image = imageGirl.image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
