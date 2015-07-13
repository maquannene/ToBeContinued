//
//  UIScrollView+MQPullToRefresh.m
//  MQPullToRefreshDemo
//
//  Created by 马权 on 3/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "UIScrollView+MQPullToRefresh.h"
#import "MQPullToRefreshView.h"
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (MQPullToRefresh)

- (MQPullToRefreshView *)pullToRefreshView {
    MQPullToRefreshView *pullToRefreshView = objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
    if (!pullToRefreshView) {
        pullToRefreshView = [[MQPullToRefreshView alloc] initWithScrollView:self];
        objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView, pullToRefreshView, OBJC_ASSOCIATION_RETAIN);
        [pullToRefreshView release];
    }
    return pullToRefreshView;
}

- (void)addActionHandlerOnPullToRefreshView:(MQPullToRefreshType)type
                            triggerDistance:(NSInteger)triggerDistance
                        requestRefreshBlock:(void (^) (void))request
{
    if (type == MQPullToRefreshTypeTop) {
        self.pullToRefreshView.type = type;
        self.pullToRefreshView.triggerDistance = (triggerDistance > 0) ? triggerDistance : 60;
        self.pullToRefreshView.requestRefreshBlock = request;
        [self addSubview:self.pullToRefreshView];
        [self.pullToRefreshView setNeedsLayout];
    }
}

- (void)setShowPullToRefreshView:(BOOL)showPullToRefreshView {
    self.pullToRefreshView.show = showPullToRefreshView;
}

- (BOOL)showPullToRefreshView {
    return self.pullToRefreshView.show;
}

@end
