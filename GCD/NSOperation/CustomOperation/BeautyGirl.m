//
//  BeautyGirl.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/17.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "BeautyGirl.h"

@implementation BeautyGirl

+(instancetype)girlWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
