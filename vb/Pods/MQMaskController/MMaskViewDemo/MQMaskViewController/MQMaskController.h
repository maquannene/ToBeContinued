//
//  MQMaskView.h
//  MQMaskViewDemo
//
//  Created by 马权 on 3/9/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MQMaskControllerType) {
    MQMaskControllerDefault,                     //  调用dismiss消失
    MQMaskControllerTipDismiss,                  //  调用dismiss消失、点击遮罩层消失
    MQMaskControllerDelayDismiss,                //  调用dismiss消失、延迟时间消失
    MQMaskControllerAll                          //  调用dismiss消失、点击遮罩层消失、延迟时间消失
};

@class MQMaskController;

typedef void(^MQMaskControllerShowAnimationState)(UIView *maskView, UIView* contentView);
typedef void(^MQMaskControllerCloseAnimationState)(UIView *maskView, UIView* contentView);

@protocol MQMaskControllerDelegate <NSObject>

@optional

- (void)maskControllerWillShow:(MQMaskController *)maskController;

- (void)maskControllerDidShow:(MQMaskController *)maskController;

- (void)maskControllerWillDismiss:(MQMaskController *)maskController;

- (void)maskControllerDidDismiss:(MQMaskController *)maskController;     /*you maybe need release instance here*/

@end

@interface MQMaskController : NSObject

@property (assign, nonatomic) id<MQMaskControllerDelegate> delegate;
@property (retain, nonatomic, readonly) UIView *maskView;               //  可设置遮罩层颜色

/**
 *  条件初始化一个遮罩。
 *
 *  @param type 类型
 *  @param view 内容层
 *
 *  @return 实例
 */
- (instancetype)initMaskController:(MQMaskControllerType)type
                   withContentView:(UIView *)view
                     contentCenter:(BOOL)contentCenter
                         delayTime:(CGFloat)delayTime;

//  设置是注意cycle retain
- (void)setShowAnimationState:(MQMaskControllerShowAnimationState)showAnimationState;
- (void)setCloseAnimationState:(MQMaskControllerCloseAnimationState)closeAnimationState;

/**
 *  显示maskController的内容
 */
- (void)showWithAnimated:(BOOL)animated completion:(void(^)(void))completion;

/**
 *  消失掉maskController
 */
- (void)dismissWithAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end
