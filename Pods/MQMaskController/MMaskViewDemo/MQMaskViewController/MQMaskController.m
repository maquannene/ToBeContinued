//
//  MQMaskView.m
//  MQMaskViewDemo
//
//  Created by 马权 on 3/9/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "MQMaskController.h"

#define kMQMaskControllerSystemVersion [UIDevice currentDevice].systemVersion.floatValue
#define kMQMaskControllerCurrentDevice [UIDevice currentDevice].userInterfaceIdiom

@interface MQMaskController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL contentViewCenter;       //  内容是否显示在中心。
@property (nonatomic, assign) BOOL isShowAnimated;
@property (nonatomic, copy) MQMaskControllerShowAnimationState showAnimationState;
@property (nonatomic, copy) MQMaskControllerCloseAnimationState closeAnimationState;

@end

@implementation MQMaskController

- (void)dealloc
{
    [_maskView release];
    _maskView = nil;
    [_contentView release];
    _contentView = nil;
    self.showAnimationState = nil;
    self.closeAnimationState = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _contentViewCenter = NO;
        
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //  8.0+ 和 8.0-加的地方不一样。
        if (kMQMaskControllerSystemVersion < 8.0) {
            [[[[UIApplication sharedApplication].keyWindow subviews] objectAtIndex:0] addSubview:_maskView];
        }
        //  8.0+加载keyWindow上，因为在8.0+的系统上，keyWindow上的view会跟随转屏旋转。
        else {
            [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
        }
        
        _maskView.frame = CGRectMake(0, 0, getInterfaceScreenSize().width, getInterfaceScreenSize().height);
        //  添加转屏通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)view {
    self = [self init];
    if (self) {
        self.contentView = view;
    }
    return self;
}

- (instancetype)initMaskController:(MQMaskControllerType)type
                   withContentView:(UIView *)view
                     contentCenter:(BOOL)contentCenter
                         delayTime:(CGFloat)delayTime {
    self = [self initWithContentView:view];
    if (self) {
        self.contentViewCenter = contentCenter;
        
        //  默认类型
        if (type == MQMaskControllerDefault) {
            
        }
        
        //  点击消失
        if (type == MQMaskControllerTipDismiss) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
            tapGesture.delegate = self;
            [_maskView addGestureRecognizer:tapGesture];
            [tapGesture release];
        }
        
        //  延迟消失
        if (type == MQMaskControllerDelayDismiss) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:delayTime];
        }
        
        //
        if (type == MQMaskControllerAll) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
            tapGesture.delegate = self;
            [_maskView addGestureRecognizer:tapGesture];
            [tapGesture release];
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:delayTime];
        }
    }
    return self;
}

- (void)dismiss {
    [self dismissWithAnimated:_isShowAnimated completion:nil];
}

#pragma mark - Public

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    _isShowAnimated = animated;
    //  如果设置了内容中心，就显示在中心
    if (_contentViewCenter) {
        self.contentView.center = _maskView.center;
    }
    
    if ([_delegate respondsToSelector:@selector(maskControllerWillShow:)]) {
        [_delegate maskControllerWillShow:self];
    }
    
    [_maskView addSubview:self.contentView];
    //  如果设置了动画，要进行动画。
    if (animated) {
        [self showwithAnimated:^{
            if (completion) {
                completion();
            }
            if ([_delegate respondsToSelector:@selector(maskControllerDidShow:)]) {
                [_delegate maskControllerDidShow:self];
            }
        }];
    }
    else {
        if (completion) {
            completion();
        }
        if ([_delegate respondsToSelector:@selector(maskControllerDidShow:)]) {
            [_delegate maskControllerDidShow:self];
        }
    }
}



- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    //  如果点击调用隐藏，那么取消延时隐藏。
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    
    if ([_delegate respondsToSelector:@selector(maskControllerWillDismiss:)]) {
        [_delegate maskControllerWillDismiss:self];
    }
    
    if (animated) {
        [self dismissWithAnimated:^{
            [_maskView removeFromSuperview];
            if ([_delegate respondsToSelector:@selector(maskControllerDidDismiss:)]) {
                [_delegate maskControllerDidDismiss:self];
            }
            if (completion) {
                completion();
            }
        }];
    }
    else {
        [_maskView removeFromSuperview];
        if ([_delegate respondsToSelector:@selector(maskControllerDidDismiss:)]) {
            [_delegate maskControllerDidDismiss:self];
        }
        if (completion) {
            completion();
        }
    }
}

#pragma mark - Private

- (void)showwithAnimated:(void (^)())complete {
    
    //  如果设置了动画状态
    if (self.showAnimationState) {
        [UIView animateWithDuration:.3 animations:^{
            self.showAnimationState(_maskView, _contentView);
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
    //  否则默认动画
    else {
        _contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        _maskView.alpha = 0.01;
        [UIView animateWithDuration:.3 animations:^{
            _contentView.transform = CGAffineTransformMakeScale(1, 1);
            _contentView.alpha = 1.0;
            _maskView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
}

- (void)dismissWithAnimated:(void (^)())complete {
    
    if (self.closeAnimationState) {
        [UIView animateWithDuration:.3 animations:^{
            self.closeAnimationState(_maskView, _contentView);
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
    else {
        [UIView animateWithDuration:.3 animations:^(){
            _contentView.transform = CGAffineTransformMakeScale(.01, .01);
            _contentView.alpha = .1;
            _maskView.alpha = .1;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate
//  这个方法是当点击自定义contentView时，不要触发手势。 否则手就拦截了本身要传给contentView的手势消息。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:_maskView];
    if (CGRectContainsPoint(self.contentView.frame, point)) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark -
#pragma mark - Notify
- (void)orientationDidChange:(NSNotification *)notify {
    CGFloat animateDuration;
    if (kMQMaskControllerCurrentDevice == UIUserInterfaceIdiomPhone) {
        animateDuration = 0.3;
    }
    else {
        animateDuration = 0.4;
    }
    
    [UIView animateKeyframesWithDuration:animateDuration delay:0.0 options:(UIViewKeyframeAnimationOptionLayoutSubviews) animations:^{
        //  重新设置maskView的大小
//        _maskView.frame = CGRectMake(0, 0, getInterfaceScreenSize().width, getInterfaceScreenSize().height);
        //  设置了UIViewAutoresizingFlexibleWidth 和 UIViewAutoresizingFlexibleHeight 就不用转屏的时候在设置frame了
        
        //  重新设置contentView的位置
        if (_contentViewCenter) {
            _contentView.center = _maskView.center;
        }
        
        //  转屏触发contentView的layoutSubview:,重新布局
        [_contentView setNeedsDisplay];
        
    } completion:^(BOOL finished) {
        
    }];
}

CGSize getInterfaceScreenSize() {
    CGSize screenSize;
    if (kMQMaskControllerSystemVersion < 8.0 && kMQMaskControllerSystemVersion >= 7.0) {
        BOOL isCurrentOrientationPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
        int width = [[UIScreen mainScreen] bounds].size.width;
        int height = [[UIScreen mainScreen] bounds].size.height;
        screenSize.width = isCurrentOrientationPortrait ? width : height;
        screenSize.height = isCurrentOrientationPortrait ? height : width;
    }
    if (kMQMaskControllerSystemVersion >= 8.0 && kMQMaskControllerSystemVersion < 10.0) {
        screenSize = [UIApplication sharedApplication].keyWindow.frame.size;
    }
    return screenSize;
}

@end
