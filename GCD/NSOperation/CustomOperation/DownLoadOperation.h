//
//  DownLoadOperation.h
//  GCD
//
//  Created by zhangzhenglong on 2017/6/18.
//  Copyright © 2017年 zhangzhenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DownLoadOperation : NSOperation
@property(nonatomic,copy)NSString * imgUrl;
@property(nonatomic,strong)NSIndexPath * currentIndexPath;
@property(nonatomic,copy)void (^DidFishedDownLoadBlock)(UIImage * image,DownLoadOperation * operation);
@end
