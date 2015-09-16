//
//  MQPullToRefreshView.h
//  MQPullToRefreshDemo
//
//  Created by 马权 on 3/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MQPullToRefreshState) {
    MQPullToRefreshStateNormal,                     //  normal
    MQPullToRefreshStateWillRefresh,                //  will and can refresh
    MQPullToRefreshStateRefreshing,                 //  refreshing
    MQPullToRefreshStateRefreshSucceed,             //  not necessary
    MQPullToRefreshStateRefreshFailed               //  not necessary
};

typedef NS_ENUM(NSInteger, MQPullToRefreshType) {
    MQPullToRefreshTypeTop,
    MQPullToRefreshTypeBottom
};

@class MQPullToRefreshView;

@protocol MQPullToRefreshViewDelegate <NSObject>

@optional
- (void)pullToRefreshView:(MQPullToRefreshView *)refreshView willChangeState:(MQPullToRefreshState)state;
- (void)pullToRefreshView:(MQPullToRefreshView *)refreshView didChangeState:(MQPullToRefreshState)state;

@end

typedef void (^ActionHandleBlock)(void);

@interface MQPullToRefreshView : UIView

@property (assign, nonatomic) MQPullToRefreshType type;                 //  top or bottom
@property (copy, nonatomic) ActionHandleBlock requestRefreshBlock;      //  trigger requestRefresh
@property (assign, nonatomic) CGFloat triggerDistance;                  //  pull distance of trigger refresh. default: 60

@property (assign, nonatomic) MQPullToRefreshState state;               //  current view state
@property (assign, nonatomic) BOOL show;
@property (assign, nonatomic) id<MQPullToRefreshViewDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

//  custom refresh View according to different state
- (void)customRefreshView:(UIView *)view forState:(MQPullToRefreshState)state;

//  force refresh: enter MQPullToRefreshStateRefreshing
- (void)refreshing;
//  refresh finish: enter MQPullToRefreshStateRefreshSucceed or MQPullToRefreshStateRefreshFailed
- (void)refreshSucceed:(BOOL)isSucceed duration:(CGFloat)duration;
//  refresh done: enter MQPullToRefreshStateNormal
- (void)refreshDone;

@end
