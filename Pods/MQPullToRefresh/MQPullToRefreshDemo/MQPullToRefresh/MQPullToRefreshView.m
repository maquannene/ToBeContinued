//
//  MQPullToRefreshView.m
//  MQPullToRefreshDemo
//
//  Created by 马权 on 3/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "MQPullToRefreshView.h"

@interface MQPullToRefreshView ()

{
@private
    UIScrollView *_scrollView;
    BOOL _show;
}

@property (retain, nonatomic) NSMutableArray *customViewArray;

@end

@implementation MQPullToRefreshView

@synthesize show = _show;

- (void)dealloc {
    [self setShow:NO];
    [_customViewArray release];
    [super dealloc];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        _customViewArray = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
        _type = MQPullToRefreshTypeTop;
        _triggerDistance = 60;
        _state = MQPullToRefreshStateNormal;
        _show = NO;
        _scrollView = scrollView;
    }
    return self;
}

#pragma mark -
#pragma mark - Public
- (void)customRefreshView:(UIView *)view forState:(MQPullToRefreshState)state {
    [_customViewArray replaceObjectAtIndex:(NSInteger)state withObject:view];
    [self setNeedsLayout];
}

- (void)refreshing {
    _state = MQPullToRefreshStateWillRefresh;
    [_scrollView setContentOffset:CGPointMake(0, -_triggerDistance) animated:YES];
    self.state = MQPullToRefreshStateRefreshing;
}

- (void)refreshSucceed:(BOOL)isSucceed duration:(CGFloat)duration {
    if (isSucceed) {
        self.state = MQPullToRefreshStateRefreshSucceed;
    }
    else {
        self.state = MQPullToRefreshStateRefreshFailed;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshDone];
    });
}

- (void)refreshDone {
    self.state = MQPullToRefreshStateNormal;
}

#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    if ([keyPath isEqualToString:@"contentSize"]) {
        //        NSLog(@"  contentSize = %@", NSStringFromCGSize([[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue]));
    }
    if ([keyPath isEqualToString:@"frame"]) {
        //        NSLog(@"  frame = %@", NSStringFromCGRect([[change valueForKey:NSKeyValueChangeNewKey] CGRectValue]));
    }
}

- (void)scrollViewDidScroll:(CGPoint)offset {
    
    CGFloat beyondDistance;
    if (_type == MQPullToRefreshTypeTop) {
        beyondDistance = ABS(offset.y);
        //  当前在刷新
        if (_state == MQPullToRefreshStateRefreshing) {
            CGFloat offsetY;
            offsetY = MIN(beyondDistance, _triggerDistance);
            NSLog(@"offsetY = %f", offsetY);
            _scrollView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        }
        else {
            if (_state == MQPullToRefreshStateWillRefresh &&
                !_scrollView.dragging) {
                self.state = MQPullToRefreshStateRefreshing;        //  刷新
            }
            else if (_state == MQPullToRefreshStateNormal &&
                     beyondDistance > _triggerDistance &&
                     _scrollView.dragging) {
                self.state = MQPullToRefreshStateWillRefresh;       //  将刷新
            }
            else if(_state != MQPullToRefreshStateNormal &&
                    beyondDistance < _triggerDistance) {
                self.state = MQPullToRefreshStateNormal;            //  正常
            }
        }
    }
    else {
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.type == MQPullToRefreshTypeTop) {
        self.frame = CGRectMake(0, -_triggerDistance, _scrollView.frame.size.width, _triggerDistance);
    }
    else {
        
    }
    [self changeCustomView];
}

- (void)changeCustomView {
    UIView *view = _customViewArray[_state];
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    view.frame = CGRectMake((self.frame.size.width - view.frame.size.width) / 2,
                            (self.frame.size.height - view.frame.size.height) / 2,
                            view.frame.size.width,
                            view.frame.size.height);
    [self addSubview:view];
}

- (void)adjusetContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _scrollView.contentInset = contentInset;
                             [_scrollView setContentOffset:CGPointMake(0, -contentInset.top) animated:NO];
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    });
}

#pragma mark - set and get

- (void)setShow:(BOOL)show {
    self.hidden = !show;
    if (_show != show) {
        _show = show;
        if (_show) {
            [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [_scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
        else {
            [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [_scrollView removeObserver:self forKeyPath:@"contentSize"];
            [_scrollView removeObserver:self forKeyPath:@"frame"];
        }
    }
}

- (BOOL)show {
    return _show;
}

- (void)setState:(MQPullToRefreshState)state {
    if (_state != state) {
        if ([_delegate respondsToSelector:@selector(pullToRefreshView:willChangeState:)]) {
            [_delegate pullToRefreshView:self willChangeState:state];
        }
        _state = state;
        switch (state) {
            case MQPullToRefreshStateNormal:
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     _scrollView.contentInset = UIEdgeInsetsZero;
                                 }
                                 completion:^(BOOL finished) {
                                     [self setNeedsLayout];
                                     [self layoutIfNeeded];
                                 }];
                break;
            case MQPullToRefreshStateRefreshing:
                [self adjusetContentInset:UIEdgeInsetsMake(_triggerDistance, 0, 0, 0) animated:YES completion:nil];
                if (_requestRefreshBlock) {
                    _requestRefreshBlock();
                }
            case MQPullToRefreshStateWillRefresh:
            case MQPullToRefreshStateRefreshFailed:
            case MQPullToRefreshStateRefreshSucceed:
                [self setNeedsLayout];
                [self layoutIfNeeded];
            default:
                break;
        }
        
        if ([_delegate respondsToSelector:@selector(pullToRefreshView:didChangeState:)]) {
            [_delegate pullToRefreshView:self didChangeState:state];
        }
    }
}

@end
