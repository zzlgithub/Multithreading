//
//  DownLoadOperation.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/18.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "DownLoadOperation.h"

@implementation DownLoadOperation

//自定义main方法执行想要执行的任务
-(void)main{
     @try {
         NSLog(@"DownLoadOperation--%@--",[NSThread currentThread]);
         [self downloadImage:self.imgUrl];
         
     }@catch (NSException * e) {
         NSLog(@"Exception %@", e);
     }
}

- (void)downloadImage:(NSString *)imgUrl{
    NSLog(@"正在下载图片的线程");
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
@end
