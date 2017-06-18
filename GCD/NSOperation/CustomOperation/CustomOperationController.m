//
//  CustomOperationController.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/17.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "CustomOperationController.h"
#import "CustomOperationCell.h"
#import "BeautyGirl.h"
#import "DownLoadOperation.h"

#define K_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define K_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

/**
 *  自定义操作  并加入操作队列
 */



@interface CustomOperationController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  数据源
 */
@property (nonatomic,strong)NSMutableArray * dataSource;
/**
 *  队列
 */
@property(nonatomic,strong)NSOperationQueue * queue;

/**
 *  操作
 */
@property(nonatomic,strong)NSMutableDictionary *operations;

/**
 *  图片缓存
 */
@property(nonatomic,strong)NSMutableDictionary *imagesCache;

/**
 *  需要加载的图片 耗时操作按需加载
 */
@property (nonatomic,strong)NSMutableArray * needLoadImagesArr;

/**
 *  是否滚动到顶部
 */
@property (nonatomic,assign)BOOL scrollToToping;

@end

static NSString * const identifier = @"CustomOperationCell";
@implementation CustomOperationController

#pragma mark   -------- 懒加载 --------
- (NSMutableArray *)dataSource{
    if (nil == _dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

-(NSOperationQueue *)queue{
    if (nil == _queue) {
        _queue = [[NSOperationQueue alloc] init];
        //控制异步操作下载 最多开启线程条数
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (NSMutableDictionary *)operations{
    if (nil == _operations) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}

- (NSMutableDictionary *)imagesCache{
    if (nil == _imagesCache) {
        _imagesCache = [NSMutableDictionary dictionary];
    }
    return _imagesCache;
}

- (NSMutableArray *)needLoadImagesArr{
    if (nil == _needLoadImagesArr) {
        _needLoadImagesArr = [NSMutableArray array];
    }
    return _needLoadImagesArr;
}
#pragma mark   ------  生命周期 - -----

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
    self.title = @"CustomOperationController";
    self.tableView.rowHeight = 180;
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomOperationCell" bundle:nil] forCellReuseIdentifier:identifier];

}

- (void)drawCell:(CustomOperationCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BeautyGirl * girl = self.dataSource[indexPath.row];
    cell.girl = girl;
    if (self.needLoadImagesArr.count > 0 &&[self.needLoadImagesArr indexOfObject:indexPath]==NSNotFound) {
        return;
    }
    
    if (self.scrollToToping) {//滚动到顶部
        return;
    }
  
    
#pragma mark   -----  异步下载图片  -------
    //获取缓存图片
    UIImage *image=self.imagesCache[girl.imgUrl];
    if (image) {
        cell.imageGirl.image=image;
    }else{
        //先添加占位图
        cell.imageGirl.image=[UIImage imageNamed:@"network"];
        
        //获取操作任务
        DownLoadOperation * operation=self.operations[girl.imgUrl];
        if (operation) {//正在操作
        }else{//没有操作任务
            DownLoadOperation * operation = [[DownLoadOperation alloc] init];
            operation.imgUrl = girl.imgUrl;
            operation.currentIndexPath=indexPath;
            //缓存操作
            self.operations[girl.imgUrl]=operation;
            
            __weak typeof(self)weakSelf = self;
            //异步下载结束回调
            operation.DidFishedDownLoadBlock = ^(UIImage * image,DownLoadOperation * operation){
                
                //缓存已下载图片
                self.imagesCache[operation.imgUrl]=image;
                
                //移除已经完成操作任务
                [weakSelf.operations removeObjectForKey:operation.imgUrl];
                
                CustomOperationCell * cell=[self.tableView cellForRowAtIndexPath:operation.currentIndexPath];
                cell.imageGirl.image=image;
                
                //刷新已下载完成的图片
                [self.tableView reloadRowsAtIndexPaths:@[operation.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                NSLog(@"图片下载完成 currentThread--%@--",[NSThread currentThread]);
                
            };
            
            //添加到操作队列异步下载
            [self.queue addOperation:operation];
        }
    }
}

#pragma mark    UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomOperationCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    BeautyGirl * girl = self.dataSource[indexPath.row];
    cell.girl = girl;
    [self drawCell:cell withIndexPath:indexPath];
    return cell;
}

#pragma mark   ----  UITableViewDelegate   ----

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark   ----  UIScrollViewDelegate   ----

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    self.scrollToToping = YES;
    return YES;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.scrollToToping = NO;
    [self loadContent];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    self.scrollToToping = NO;
    [self loadContent];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //开始拖拽时 清空需要加载的数组
    [self.needLoadImagesArr removeAllObjects];
}

#pragma mark   -------   按需加载图片 --------

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSIndexPath * targetIndexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath * visibleIndexPath = [[self.tableView indexPathsForVisibleRows] firstObject];
    NSInteger skipCount = 6;
    if (labs(visibleIndexPath.row - targetIndexPath.row) > skipCount) {
        
        NSArray * temp = [self.tableView indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y,K_SCREENWIDTH,K_SCREENHEIGHT)];
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
        if (velocity.y<0) {
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row + 3 < self.dataSource.count) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:0]];
            }
        } else {
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row>3) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            }
        }
        [self.needLoadImagesArr addObjectsFromArray:arr];
    }
}


//用户触摸屏幕时 就开始加载内容
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!self.scrollToToping) {
        [self.needLoadImagesArr removeAllObjects];
        [self loadContent];
    }
    return [self.tableView hitTest:point withEvent:event];
}

- (void)loadContent{
    if (self.scrollToToping) {
        return;
    }
    if (self.tableView.indexPathsForVisibleRows.count<=0) {
        return;
    }
    if (self.tableView.visibleCells && self.tableView.visibleCells.count>0) {
        for (int i = 0; i < self.tableView.visibleCells.count; i ++) {
            CustomOperationCell *cell = (CustomOperationCell *)self.tableView.visibleCells[i];
            NSIndexPath * visibleIndexPath = [self.tableView indexPathsForVisibleRows][i];
            [self drawCell:cell withIndexPath:visibleIndexPath];
            
        }
    }
}

#pragma mark    ---- 数据源  ---
- (void)getData{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"girls.plist" ofType:nil];
        
        NSArray * girls = [NSArray arrayWithContentsOfFile:path];
        for (int i = 0; i < girls.count; i ++) {
            NSDictionary * girlDic = girls[i];
            BeautyGirl * girl = [BeautyGirl girlWithDict:girlDic];
            [weakSelf.dataSource addObject:girl];
        }
        
        NSLog(@"dispatch_get_global_queue: %@",[NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            NSLog(@"dispatch_get_main_queue: %@",[NSThread currentThread]);
        });
        
    });
}
- (void)dealloc{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
