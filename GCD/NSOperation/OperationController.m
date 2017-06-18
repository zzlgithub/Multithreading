//
//  OperationController.m
//  GCD
//
//  Created by zhangzhenglong on 2017/6/16.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import "OperationController.h"
#import "OperationDetailController.h"

@interface OperationController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray * dataSource;

@end

static NSString * const identifier = @"TableViewCell";
@implementation OperationController

- (NSMutableArray *)dataSource{
    if (nil == _dataSource) {
        _dataSource = [NSMutableArray arrayWithObjects:@"NSInvocationOperation",@"NSBlockOperation",@"NSInvocationOperation + NSOperationQueue",@"NSBlockOperation + NSOperationQueue",@"NSInvocationOperation + NSBlockOperation + NSOperationQueue",@"NSBlockOperation + addDependency(依赖)",@"线程同步",nil];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Operation";
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    
}
#pragma mark ------- UITableViewDataSource   ---

-  (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OperationDetailController * vc = [[OperationDetailController alloc] init];
    vc.operationType = indexPath.row + 10;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
