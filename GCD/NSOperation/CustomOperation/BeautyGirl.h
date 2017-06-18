//
//  BeautyGirl.h
//  GCD
//
//  Created by zhangzhenglong on 2017/6/17.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeautyGirl : NSObject
@property (nonatomic,copy)NSString * name;
@property (nonatomic,copy)NSString * no;
@property (nonatomic,copy)NSString * imgUrl;

+(instancetype)girlWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
