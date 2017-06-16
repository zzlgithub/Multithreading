//
//  GCDViewController.h
//  GCD
//
//  Created by zhangzhenglong on 2017/6/15.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GCD_Type){//  同步/异步 和  串行队列/并行队列组合
    dispatch_sync_DISPATCH_QUEUE_SERIAL = 10,
    dispatch_sync_DISPATCH_QUEUE_CONCURREN,
    dispatch_sync_mainQueue,
    dispatch_sync_globalQueue,
    dispatch_async_DISPATCH_QUEUE_SERIAL,
    dispatch_async_DISPATCH_QUEUE_CONCURRENT,
    dispatch_async_mainQueue,
    dispatch_async_globalQueue
};

typedef NS_ENUM(NSInteger, Task_Type){//任务执行顺序
    Task_Type1 = 20,
    Task_Type2,
    Task_Type3,
    Task_Type4,
    Task_Type5,
};

typedef NS_ENUM(NSInteger, GCD_OtherUse){
    Dispatch_once = 30,//单利
    Dispatch_after,//延时
    Dispatch_group,//并发队列任务执行 反馈是否执行完毕
    Dispatch_barrier_async,//并发队列任务执行控制
    Dispatch_barrier_asyncControll//并发队列任务执行控制
};

@interface GCDViewController : UIViewController
@property (nonatomic,assign)GCD_Type gcdType;
@property (nonatomic,assign)Task_Type taskType;
@property (nonatomic,assign)GCD_OtherUse gcdOtherUse;
@end
