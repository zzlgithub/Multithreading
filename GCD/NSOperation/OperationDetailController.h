//
//  OperationDetailController.h
//  GCD
//
//  Created by zhangzhenglong on 2017/6/16.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,OperationType) {
    Operation1 = 10,
    Operation2,
    Operation3,
    Operation4,
    Operation5,
    Operation6,
    Operation7
};

@interface OperationDetailController : UIViewController

@property (nonatomic,assign) OperationType operationType;
@end
