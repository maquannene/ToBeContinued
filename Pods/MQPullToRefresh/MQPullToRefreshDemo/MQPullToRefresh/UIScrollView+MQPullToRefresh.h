//
//  UIScrollView+MQPullToRefresh.h
//  MQPullToRefreshDemo
//
//  Created by 马权 on 3/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

/*
    MQPullToRefreshView *pullToRefreshView; 提供给外界，进行自定义设置
    BOOL showPullToRefreshView;             是否开启刷新界面
 
    //  一个方法添加刷新handle
    - (void)addActionHandlerOnPullToRefreshView:(MQPullToRefreshType)type
                                triggerDistance:(NSInteger)triggerDistance
                           refreshCompleteBlock:(void (^) (void))complete;
 */

#import <UIKit/UIKit.h>
#import "MQPullToRefreshView.h"

@class MQPullToRefreshView;

@interface UIScrollView (MQPullToRefresh)

@property (retain, nonatomic, readonly) MQPullToRefreshView *pullToRefreshView;
@property (assign, nonatomic) BOOL showPullToRefreshView;

/**
 *  para1:  top pull down or bottom pull up
 *  para2:  distance of trigger refresh
 *  para3:  trigger requestRefresh block
 */
- (void)addActionHandlerOnPullToRefreshView:(MQPullToRefreshType)type
                            triggerDistance:(NSInteger)triggerDistance
                        requestRefreshBlock:(void (^) (void))request;

@end
