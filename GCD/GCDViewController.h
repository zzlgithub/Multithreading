//
//  GCDViewController.h
//  GCD
//
//  Created by zhangzhenglong on 2017/6/15.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GCD_Type){
    dispatch_sync_DISPATCH_QUEUE_SERIAL = 10,
    dispatch_sync_DISPATCH_QUEUE_CONCURREN,
    dispatch_sync_mainQueue,
    dispatch_sync_globalQueue,
    dispatch_async_DISPATCH_QUEUE_SERIAL,
    dispatch_async_DISPATCH_QUEUE_CONCURRENT,
    dispatch_async_mainQueue,
    dispatch_async_globalQueue
};

typedef NS_ENUM(NSInteger, Task_Type){
    Task_Type1 = 20,
    Task_Type2,
    Task_Type3,
    Task_Type4,
    Task_Type5,
};

typedef NS_ENUM(NSInteger, GCD_OtherUse){
    Dispatch_once = 30,
    Dispatch_after,
    Dispatch_group,
    Dispatch_barrier_async
};

@interface GCDViewController : UIViewController
@property (nonatomic,assign)GCD_Type gcdType;
@property (nonatomic,assign)Task_Type taskType;
@property (nonatomic,assign)GCD_OtherUse gcdOtherUse;
@end
