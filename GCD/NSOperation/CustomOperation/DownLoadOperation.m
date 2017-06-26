//
//  DownLoadOperation.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/18.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "DownLoadOperation.h"
/**
 *  如果想做一个同步的方法，你只要重写main这个函数，在里面添加要的操作。如果想定义异步并发操作的方法的，就重写start方法。在你添加进operationQueue中的时候系统将自动调用你这个start方法，这时将不再先调用main里面的方法。
    如果需要自定义并发执行的 Operation，必须重写 start、main、isExecuting、isFinished、isAsynchronous 方法
 */

@interface DownLoadOperation (){
BOOL        executing;  // 执行中
BOOL        finished;   // 已完成
}
@end


@implementation DownLoadOperation

- (instancetype)init{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (void)start {
    
    //任务是否被取消，如果取消了，实现相应的KVO
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    //没被取消，开始执行任务
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}



//自定义main方法执行想要执行的任务
-(void)main{
     @try {
          @autoreleasepool {
        
              [self downloadImage:self.imgUrl];
              
              //任务执行完成  要实现相应的KVO
              [self willChangeValueForKey:@"isFinished"];
              [self willChangeValueForKey:@"isExecuting"];
              executing = NO;
              finished = YES;
              [self didChangeValueForKey:@"isExecuting"];
              [self didChangeValueForKey:@"isFinished"];
          }
         
     }@catch (NSException * e) {
         NSLog(@"Exception %@", e);
     }
}

- (void)downloadImage:(NSString *)imgUrl{
    NSLog(@"正在下载图片的线程%@ ",[NSThread currentThread]);
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl]];
    NSURLSession * session = [NSURLSession sharedSession];
    __weak typeof(self)weakSelf = self;
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *imgae=[UIImage imageWithData:data];
            
            if (imgae && imgae!= nil) {
                if (self.DidFishedDownLoadBlock) {
                    weakSelf.DidFishedDownLoadBlock(imgae,self);
                }
            }
        });
       
    }];
    [task resume];
}


- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

@end
