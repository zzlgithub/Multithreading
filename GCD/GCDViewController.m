//
//  GCDViewController.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/15.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "GCDViewController.h"
@interface GCDViewController ()


@end


/** 总结:
 *  同步执行：只要是同步执行的任务，都会在当前线程执行，不会另开线程。
 
    异步执行：只要是异步执行的任务，都会另开线程，在别的线程执行
 
    同步（sync） 和 异步（async）的主要区别在于会不会阻塞当前线程，直到 Block 中的任务执行完毕！
 
    同步（sync） 操作，它会阻塞当前线程并等待 Block 中的任务执行完毕，然后当前线程才会继续往下运行
 
    异步（async）操作，当前线程会直接往下执行，它不会阻塞当前线程
 
    队列：用于存放任务。一共有两种队列， 串行队列 和 并行队列。
    
    串行队列 中的任务会根据队列的定义 FIFO 的执行，一个接一个的先进先出的进行执行。
 
    并行队列 中的任务根据同步或异步有不同的执行方式
 
    对照表如下:
 
                     同步执行                        异步执行
 
    串行队列:      当前线程一个一个执行             开辟子线程，一个一个执行
    
    并行队列:      当前线程一个一个执行             开辟很多子线程，同时执行
 
 
   主队列：是一个特殊的串行队列。它用于刷新 UI，任何需要刷新 UI 的工作都要在主队列执行，所以一
          般耗时的任务都要放到别的线程执行
          是和主线程相关联的队列，主队列是GCD自带的一种特殊的串行队列，放在主队列中得任务，都会放到主线程中执行。
          如果把任务放到主队列中进行处理，那么不论处理函数是异步的还是同步的都不会开启新的线程。
 
 
   全局并行队列：并行任务一般都加入到这个队列
 */


@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self gcdMedthod];
    /*
     通过测试我们得出如下几个结论
     1.dispatch_sync添加任务到队列，不会创建新的线程都是在当前线程中处理的。无论添加到串行队列里或者并行队列里，都是串行效果，因为这个方法是等任务执行完成以后才会返回。
     2.dispatch_async添加任务到
     mainQueue不创建线程，在主线程中串行执行
     globalQueue 和 并行队列：根据任务系统决定开辟线程个数
     串行对列：创建一个线程：串行执行。
     
     */
   
    [self printTask];
    
    
    [self gcd_Other_use];

}





//(串行队列/并行队列)与(dispatch_async/dispatch_sync)的组合使用
-(void)gcdMedthod
{
    
    /**
     dispatch_async方法是立刻返回的，也就是说把block内容加到相应队列里后会立马返回，而dispatch_sync要等到加到队列里执行完之后才会返回。
     *
     *  队列一般就是系统的 主队列、全局队 以及 手动创建的 串行队列、并行队列
     */

    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    //相当于并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    
    switch (self.gcdType) {
        case dispatch_sync_DISPATCH_QUEUE_SERIAL:
        {
            for(int i = 0;i < 3; i++){
                dispatch_sync(serialQueue, ^{
                    NSLog(@"dispatch_sync-serialQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                });
            }

        //观察日志得结论 同步串行队列是在主线程里完成的 执行的任务是有顺序的。
            break;
        }
        case dispatch_sync_DISPATCH_QUEUE_CONCURREN:
        {
            for(int i=0;i<3;i++){
                dispatch_sync(concurrentQueue, ^{
                    NSLog(@"dispatch_sync-concurrentQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                    
                });
            }
            //观察日志发现，同步并发队列在主线程里执行，(虽然是并行队列，但这时候依然在同一个线程里执行)，因为调用的是同步方法，系统没有调度分配子线程
            break;
        }
        case dispatch_sync_mainQueue:
        {
//            for(int i=0;i<3;i++){
//                NSLog(@"dispatch_sync-mainQueue");
//                dispatch_sync(mainQueue, ^{
//                    
//                    NSLog(@"dispatch_sync-mainQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
//                    
//                });
//            }
            
          //  观察日志发现：dispatch_sync-mainQueue，发生奔溃  主线程被堵塞也就是死锁了。
            
            /**
             *  同步任务有一个特性，只要一添加到队列中就要马上执行，主队列中永远就只要一条线程——主线程，此时主线程在等待着主队列调度同步任务，而主队列发现主线程上还有任务未执行完，就不会让同步任务添加到主线程上，由此就造成了互相等待（主队列在等待主线程执行完已有的任务，而主线程又在等待主队列调度同步任务！）
             */
            
            
            
           // 如果有在主队列执行同步任务的需要可以这么处理:

            // 制作任务
            void (^task)() = ^ {
                NSLog(@"currentThread: %@", [NSThread currentThread]);
                
                // 主队列上执行同步任务
                dispatch_sync(mainQueue, ^{
                    NSLog(@"come here..... currentThread: %@", [NSThread currentThread]);
                });
                
                NSLog(@"hahaha.....currentThread:  %@", [NSThread currentThread]);
            };
            
            // 异步执行任务  
            dispatch_async(globalQueue, task);
            NSLog(@"now i'm here.....currentThread: %@",[NSThread currentThread]);
            
            //这样 主线程没有被阻塞！！！"now i'm here“出现的位置不确定，但总会先于主队列中的同步函数！主队列的同步任务被添加到全局队列的异步任务中，全局队列会先让主线程上的任务先执行完再执行同步任务！
            
            
            
            break;
        }
        case dispatch_sync_globalQueue:
        {
            for(int i=0;i<3;i++){
                dispatch_sync(globalQueue, ^{
                    
                    NSLog(@"dispatch_sync-globalQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                    
                });
            }

            //观察日志发现，同步全局队列在主线程里执行,系统没有调度分配子线程
            //  globalQueue  全局队列 系统默认分配 相当全局于并发队列
            break;
        }
        case dispatch_async_DISPATCH_QUEUE_SERIAL:
        {
            for (int i=0; i<3; i++) {
                dispatch_async(serialQueue, ^{
                    if (i==1) {
                        sleep(2);
                    }
                    NSLog(@"dispatch_async-serialQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                });
            }
            
             //异步创建了一个子线程， 在串行队列里  任务是串行执行的
            // 会开启线程，但是只开启一个线程
            break;
        }
        case dispatch_async_DISPATCH_QUEUE_CONCURRENT:
        {
            for (int i = 0; i < 3; i++) {
                dispatch_async(concurrentQueue, ^{
                    if (i==1) {
                        sleep(3);
                    }
                    NSLog(@"dispatch_async-concurrentQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                });
            }
            //分析可以看出创建了多个子线程，任务执行顺序不一定
            break;
        }
        case dispatch_async_mainQueue:
        {
            /**
             *  mainQueue是GCD本身自带的一种特殊的串行队列，所有放在主队列中的任务都会在主线程上执行。
               程序一启动，主线程就已经存在，主队列也同时就存在了，所以主队列不需要创建，只需要获取
             */
            
            
            for (int i=0; i<3; i++) {
                dispatch_async(mainQueue, ^{
                    if (i==1) {
                        sleep(3);
                    }
                    NSLog(@"dispatch_async-mainQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                });
            }
            //可以看出这种情况还是在当前线程环境中执行，并不创建线程，在主队列中，即使有异步任务，也会依次在主线程上执行
            break;
        }
        case dispatch_async_globalQueue:
        {
            for (int i=0; i<3; i++) {
                dispatch_async(globalQueue, ^{
                    
                    NSLog(@"dispatch_async-globalQueue-%d\n currentThread:%@",i,[NSThread currentThread]);
                });
            }
            //观察日志  发现 创建了多个子线程，执行顺序并不一定  globalQueue 相当与并行队列
            break;
        }
        default:
            break;
    }
}


//任务的操作顺序
- (void)printTask{
    switch (self.taskType) {
        case Task_Type1:
        {
            //打印结果是1  分析：mainQueue里存在任务1，同步线程任务，这两个任务，当执行dispatch_sync时，把打印任务2加入主队列，想要打印2必须等之前所有的任务都执行完成，这时候因为主队列里有同步线程任务，这时候相当于自己在等自己执行完成，进入死循环。
//            NSLog(@"1"); // 任务1
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                NSLog(@"2"); // 任务2
//            });
//            NSLog(@"3"); // 任务3
            
            
                 //获取主队列
                 dispatch_queue_t queue=dispatch_get_main_queue();
            
                 dispatch_async(queue, ^{
                         NSLog(@"任务1--%@",[NSThread currentThread]);
                     });
                 dispatch_async(queue, ^{
                         NSLog(@"任务2--%@",[NSThread currentThread]);
                     });
                 dispatch_async(queue, ^{
                         NSLog(@"任务3--%@",[NSThread currentThread]);
                     });
            
            //使用异步函数执行主队列中得任务  不会开辟子线程处理
            
            break;
        }
        case Task_Type2:
        {
            //打印结果1 2 3  分析：mainQueue里存在任务1，同步线程任务，当执行dispatch_sync时，拿到全局队列，
            NSLog(@"1"); // 任务1
            NSLog(@"1 %@",[NSThread currentThread]);
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSLog(@"2"); // 任务2
                NSLog(@"2 %@",[NSThread currentThread]);
            });
            NSLog(@"3"); // 任务3
            NSLog(@"3 %@",[NSThread currentThread]);
            
            break;
        }
        case Task_Type3:
        {
            dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
            NSLog(@"1"); // 任务1
            dispatch_async(queue, ^{
                NSLog(@"2 %@",[NSThread currentThread]); // 任务2
                
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSLog(@"3"); // 任务3
                });
                NSLog(@"4"); // 任务4
            });
            NSLog(@"5"); // 任务5

            break;
        }
        case Task_Type4:
        {
            //1,5,2,3,4 可以看出在全局队列里拿到主队列同步执行是没有问题的。
            NSLog(@"****************");
            NSLog(@"1"); // 任务1
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"2"); // 任务2
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"3 %@",[NSThread currentThread]); // 任务3
                });
                NSLog(@"4"); // 任务4
            });
            NSLog(@"5"); // 任务5
            break;
        }
        case Task_Type5:
        {
            //执行结果：1，4
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"1"); // 任务1
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"2"); // 任务2
                });
                NSLog(@"3"); // 任务3
            });
            NSLog(@"4"); // 任务4
            break;
        }
        default:
            break;
    }
}


//GCD其他相关应用
- (void)gcd_Other_use{
    switch (self.gcdOtherUse) {
        case Dispatch_once:
        {
            //dispatch_once的作用就是只执行一次，我们在写单例的时候可以用到
            [GCDViewController shared];
            break;
        }
        case Dispatch_after:
        {
            //延迟2s以后执行
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC* 2);
            dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"延迟2秒  doSomething");
            });
            break;
        }
        case Dispatch_group:
        {
            //队列组可以将很多队列添加到一个组里，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_async(group, globalQueue, ^{
                sleep(1);
                NSLog(@"1 %@",[NSThread currentThread]);
            });
            dispatch_group_async(group, globalQueue, ^{
                sleep(2);
                NSLog(@"3 %@",[NSThread currentThread]);
            });
            dispatch_group_async(group, globalQueue, ^{
                sleep(3);
                NSLog(@"2 %@",[NSThread currentThread]);
            });
            dispatch_group_notify(group, globalQueue, ^{
                NSLog(@"队列组里任务执行完毕  Over!");
            });
            break;
        }
        case Dispatch_barrier_async:
        {
            
            dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(concurrentQueue, ^(){
                NSLog(@" 任务1 %@",[NSThread currentThread]);
            });
            dispatch_async(concurrentQueue, ^(){
                NSLog(@"任务 2 %@",[NSThread currentThread]);
            });
            
            
            //这个方法重点是传入的 queue，当传入的 queue 是 DISPATCH_QUEUE_CONCURRENT  队列时，该方法会阻塞这个 queue（注意是阻塞 queue ，而不是阻塞当前线程），一直等到这个 queue 中排在它前面的任务都执行完成后才会开始执行自己，自己执行完毕后，再会取消阻塞，使这个 queue 中排在它后面的任务继续执行。 如果传入的是其他的 queue, 那么它就和 dispatch_async 一样了
            
            dispatch_barrier_async(concurrentQueue, ^(){
                NSLog(@"任务 1 任务 2 %@",[NSThread currentThread]);
            });
            
            
            
            /**
             *  这个方法的使用和上一个一样，传入自定义的并发队列（DISPATCH_QUEUE_CONCURRENT），它和上一个方法一样的阻塞 queue，不同的是 这个方法还会 阻塞当前线程,如果你传入的是其他的 queue, 那么它就和 dispatch_sync 一样了
             */
//            dispatch_barrier_sync(concurrentQueue, ^{
//                
//            });
            
            
            
            dispatch_async(concurrentQueue, ^(){
                NSLog(@"任务 3 %@",[NSThread currentThread]);
            });
            
            
            dispatch_barrier_async(concurrentQueue, ^{
                NSLog(@"任务 1 任务2 任务3 %@",[NSThread currentThread]);
            });
            
            
            dispatch_async(concurrentQueue, ^(){
                NSLog(@"任务4 %@",[NSThread currentThread]);
            });
            break;
        }
    
        case Dispatch_barrier_asyncControll:{
            dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
            
            for (int i = 0; i < 10; i ++) {
                
                //控制任务 6 7 8 9在 任务 5 之后执行
                if (i == 5) {
                    dispatch_barrier_async(concurrentQueue, ^(){
                        NSLog(@"任务 5 %@",[NSThread currentThread]);
                    });
                    continue;
                }
                
                dispatch_async(concurrentQueue, ^(){
                    sleep(1);
                    NSLog(@"任务%d %@",i,[NSThread currentThread]);
                });
                
                
                
            }

            break;
        }

        default:
            break;
    }
}


+ (id)shared {
    static dispatch_once_t onceToken = 0;
    __strong static GCDViewController * _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
