//
//  OperationDetailController.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/16.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "OperationDetailController.h"
//本例参考 http://blog.csdn.net/q199109106q/article/details/8566222


/**
 *  NSOperation :
 
         BOOL executing; //判断任务是否正在执行
         BOOL finished; //判断任务是否完成
         void (^completionBlock)(void); //用来设置完成后需要执行的操作
         - (void)cancel; //取消任务
         - (void)waitUntilFinished; //阻塞当前线程直到此任务执行完毕
 */

/**
 *  NSOperationQueue:
 
         NSUInteger operationCount; //获取队列的任务数
         - (void)cancelAllOperations; //取消队列中所有的任务
         - (void)waitUntilAllOperationsAreFinished; //阻塞当前线程直到此队列中的所有任务执行完毕
         [queue setSuspended:YES]; // 暂停queue
         [queue setSuspended:NO]; // 继续queue
 */


/**
 *  对于添加到queue中的operations，它们的执行顺序取决于2点：
    1.首先看看NSOperation是否已经准备好：是否准备好由对象的依赖关系确定
    2.然后再根据所有NSOperation的相对优先级来确定。优先级等级则是operation对象本身的一个属性。默认所有operation都拥有“普通”优先级,不过可以通过setQueuePriority:方法来提升或降低operation对象的优先级。优先级只能应用于相同queue中的operations。如果应用有多个operation queue,每个queue的优先级等级是互相独立的。因此不同queue中的低优先级操作仍然可能比高优先级操作更早执行。
    注意：优先级不能替代依赖关系,优先级只是对已经准备好的 operations确定执行顺序。先满足依赖关系,然后再根据优先级从所有准备好的操作中选择优先级最高的那个执行。
 */



@interface OperationDetailController ()

@end


@implementation OperationDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self operationQueue];

}


- (void)operationQueue{
    switch (self.operationType) {
        case Operation1:
        {
            //NSOperation:抽象类，不具备封装功能
            //创建操作对象，封装要执行的任务
            NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation1) object:nil];
                
                
            //执行操作
            [operation start];
            
            
            /**
             *  观察日志: 得结论：
             操作对象默认在当前线程执行，只有添加到队列中才会开启新的线程。即默认情况下，如果操作没有放到队列中queue中，都是同步执行。只有将NSOperation放到一个NSOperationQueue中,才会异步执行操作
             */
            break;
        }
        case Operation2:{
            
            //创建NSBlockOperation操作对象
            NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"NSBlockOperation---任务一currentThread：%@",[NSThread currentThread]);
                
            }];
            
            //添加操作
            [operation addExecutionBlock:^{
                NSLog(@"NSBlockOperation1--任务二-currentThread---%@",[NSThread currentThread]);
                
            }];
            
            [operation addExecutionBlock:^{
                NSLog(@"NSBlockOperation2--任务三--currentThread--%@",[NSThread currentThread]);
                
            }];
            
            //开启执行操作
            [operation start];
            
            /**
             *  通过 addExecutionBlock 这个方法可以给 Operation 添加多个执行 Block。这样 Operation 中的任务 会并发执行，它会 在主线程和其它的多个线程 执行这些任务
             
                addExecutionBlock 方法必须在 start() 方法之前执行
             */
            break;
        }
        case Operation3:{
            //创建NSInvocationOperation对象，封装操作
            NSInvocationOperation *operation1=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation3) object:nil];
            
             NSInvocationOperation *operation2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation31) object:nil];
        
        
             //创建NSOperationQueue
             NSOperationQueue * queue=[[NSOperationQueue alloc]init];
            //把操作添加到队列中
             [queue addOperation:operation1];
             [queue addOperation:operation2];
            
            /**
             *  NSOperationQueue的作⽤：NSOperation可以调⽤start⽅法来执⾏任务,但默认是同步执行的
                如果将NSOperation添加到NSOperationQueue(操作队列)中,系统会自动异步执行NSOperation中的操作
                添加操作到NSOperationQueue中，自动执行操作，自动开启线程
             */
          
            break;
        }
        case Operation4:{
            
            //创建NSInvocationOperation对象，封装操作
            NSInvocationOperation *operation1=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation4) object:nil];
            NSInvocationOperation *operation2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation41) object:nil];
            //创建对象，封装操作
            NSBlockOperation *operation3=[NSBlockOperation blockOperationWithBlock:^{
                    NSLog(@"NSBlockOperation--任务3----%@",[NSThread currentThread]);
            }];
            
            [operation3 addExecutionBlock:^{
                  NSLog(@"NSBlockOperation3--任务4----%@",[NSThread currentThread]);
                
            }];
            NSOperationQueue * queue=[[NSOperationQueue alloc]init];
            //把操作添加到队列中
            [queue addOperation:operation1];
            [queue addOperation:operation2];
            [queue addOperation:operation3];
            
            /**
             *  系统自动将NSOperationqueue中的NSOperation对象取出，将其封装的操作放到一条新的线程中执行。上面的代码示例中，一共有四个任务，operation1和operation2分别有一个任务，operation3有两个任务。一共四个任务，开启了四条线程。通过任务执行的时间可以看出，这些任务是并行执行的。
             
                队列的取出是有顺序的，与打印结果并不矛盾。这就好比，选手A,B C虽然起跑的顺序是先A,后B，然后C，但是到达终点的顺序却不一定是A,B在前，C在后。
             */
            break;
        }
        case Operation5:{
                //创建NSInvocationOperation对象，封装操作
                NSInvocationOperation *operation1=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation5) object:nil];
                
                NSInvocationOperation *operation2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation51) object:nil];
                
                //创建对象，封装操作
                NSBlockOperation *operation3=[NSBlockOperation blockOperationWithBlock:^{
                         for (int i=0; i<5; i++) {
                                NSLog(@"NSBlockOperation--任务3----%@",[NSThread currentThread]);
                            }
                }];
                
               [operation3 addExecutionBlock:^{
                             for (int i=0; i<5; i++) {
                                 NSLog(@"NSBlockOperation--任务4----%@",[NSThread currentThread]);
                                 }
               }];
            
                 //创建NSOperationQueue
                 NSOperationQueue * queue=[[NSOperationQueue alloc]init];
                 //把操作添加到队列中
                 [queue addOperation:operation1];
                 [queue addOperation:operation2];
                 [queue addOperation:operation3];
            break;
        }
        case Operation6:{
            
            //1.任务一：下载图片
            NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"下载图片 - %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:1.0];
            }];
            //2.任务二：打水印
            NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"打马赛克   - %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:1.0];
            }];
            //3.任务三：上传图片
            NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
                NSLog(@"上传图片 - %@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:1.0];
            }];
            //4.设置依赖
            [operation2 addDependency:operation1];      //任务二依赖任务一
            [operation3 addDependency:operation2];      //任务三依赖任务二
            //5.创建队列并加入任务
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];

            
            /**
             *  不管串行、并行、同步、异步这些操作。NSOperationQueue 有一个参数 maxConcurrentOperationCount 最大并发数，用来设置最多可以让多少个任务同时执行。当把它设置为 1 的时候，就是串行
                 removeDependency方法来删除依赖对象。
                 依赖关系不局限于相同queue中的NSOperation对象,NSOperation对象会管理自己的依赖, 因此完全可以在不同的queue之间的NSOperation对象创建依赖关系，唯一的限制是不能创建环形依赖，比如A依赖B，B依赖A，这是错误的
             */
            break;
        }
            
        case Operation7:{

            
            //     1. 全局的 NSOperationQueue, 所有的操作添加到同一个queue中
            //     2. 设置 queue 的 maxConcurrentOperationCount 为 1
            //     3. 如果后续操作需要Block中的结果，就需要调用每个操作的waitUntilFinished，阻塞当前线程，一直等到当前操作完成，才允许执行后面的。waitUntilFinished 要在添加到队列之后！
            
            /**
             除了等待单个Operation完成,你也可以同时等待一个queue中的所有操作,使用NSOperationQueue的waitUntilAllOperationsAreFinished方法。注意：在等待一个 queue时,应用的其它线程仍然可以往queue中添加Operation,因此可能会加长线程的等待时间。
             */
            
            NSOperationQueue * queue = [[NSOperationQueue alloc] init];
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                [NSThread sleepForTimeInterval:1];
    
                NSLog(@"operation1 - %@", [NSThread currentThread]);
                
            }];
            
            NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
                [NSThread sleepForTimeInterval:1];
                NSLog(@"operation2 - %@", [NSThread currentThread]);            }];
            
            NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
                [NSThread sleepForTimeInterval:1];
                NSLog(@"operation3 - %@", [NSThread currentThread]);
            }];
            
            [queue addOperation:operation];
            [queue addOperation:operation1];
            [queue addOperation:operation2];
            [operation waitUntilFinished];
            break;
        }
        
        default:
            break;
    }
    
}


#pragma mark    ----------- action  -----------

- (void)testOperation1{
    NSLog(@"--testOperation1--currentThread:  %@--",[NSThread currentThread]);
}


- (void)testOperation3{
    NSLog(@"--testOperation3--currentThread:  %@--",[NSThread currentThread]);
}


- (void)testOperation31{
    NSLog(@"--testOperation31--currentThread:  %@--",[NSThread currentThread]);
}



- (void)testOperation4{
    NSLog(@"--testOperation4-任务1-currentThread:  %@--",[NSThread currentThread]);
}

- (void)testOperation41{
    NSLog(@"--testOperation41-任务2-currentThread:  %@--",[NSThread currentThread]);
}

- (void)testOperation5{
    NSLog(@"--testOperation5-任务1-currentThread:  %@--",[NSThread currentThread]);
}
- (void)testOperation51{
    NSLog(@"--testOperation51-任务2-currentThread:  %@--",[NSThread currentThread]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
