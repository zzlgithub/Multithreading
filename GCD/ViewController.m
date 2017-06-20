//
//  ViewController.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/15.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "GCDViewController.h"
#import "OperationController.h"
#import "CustomOperationController.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray * dataSource;

@end

static NSString * const identifier = @"MyTableViewCell";

@implementation ViewController


#pragma mark -----  action -----
- (IBAction)gotoOperation:(id)sender {
    
    OperationController * vc = [[OperationController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoCustomOperation:(id)sender {
    CustomOperationController * vc = [[CustomOperationController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark   -------  life cycle -----
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //需要设置估值只设置 UITableViewAutomaticDimension 没有效果
    self.tableView.estimatedRowHeight = 80;
    self.tableView.sectionHeaderHeight = 60;
    
}

#pragma mark   UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * secArr = self.dataSource[section];
    return secArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSArray * secArr = self.dataSource[indexPath.section];
    cell.lable.text = secArr[indexPath.row];
    return cell;
}

#pragma mark   UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GCDViewController * gcdVC = [[GCDViewController alloc] init];
    if (indexPath.section == 0) {
        gcdVC.gcdType = indexPath.row + 10;
    }else if(indexPath.section == 1){
        gcdVC.taskType = indexPath.row + 20;
    }else{
        gcdVC.gcdOtherUse = indexPath.row + 30;
    }
    [self.navigationController pushViewController:gcdVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  self.dataSource.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,self.view.frame.size.width, 30)];
    lable.backgroundColor = [UIColor greenColor];
    lable.numberOfLines = 0;
    lable.font = [UIFont systemFontOfSize:16];
    if (section == 0) {
        lable.text = @"(串行队列/并行队列)与(dispatch_async/dispatch_sync)的组合使用";
        return lable;
    }else if(section == 1){
        lable.text = @"任务执行顺序";
        return lable;
    }else{
        lable.text = @"GCD其他应用";
        return lable;
    }
}

#pragma mark -----  data  --------
- (NSMutableArray *)dataSource{
    if (nil == _dataSource) {
        _dataSource = [NSMutableArray arrayWithObjects:@[
                       @"dispatch_sync + DISPATCH_QUEUE_SERIAL(同步 + 串行队列)",
                       @"dispatch_sync + DISPATCH_QUEUE_CONCURRENT(同步 + 并行队列)",
                       @"dispatch_sync + mainQueue(同步 + 主队列)",
                       @"dispatch_sync + globalQueue(同步 + 全局队列)",
                       @"dispatch_async + DISPATCH_QUEUE_SERIAL(异步 + 串行队列)",
                       @"dispatch_async + DISPATCH_QUEUE_CONCURRENT(异步 + 并行队列)",
                       @"dispatch_async + mainQueue(异步 + 主队列)",
                       @"dispatch_async + globalQueue(异步 + 全局队列)"],@[@"BlockTask1",@"BlockTask2",@"BlockTask3",@"BlockTask4",@"BlockTask5"],@[@"dispath_once",@"dispatch_after",@"dispatch_group",@"dispatch_barrier_async",@"Dispatch_barrier_asyncControll",@"dispatch_semaphore_t"],nil];
    }
    return _dataSource;
}
@end
