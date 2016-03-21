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

@property (nonatomic, assign) id<MQMaskControllerDelegate> delegate;
@property (nonatomic, retain, readonly) UIView *maskView;               //  可设置遮罩层颜色
@property (nonatomic, retain) UIView *contentView;                      //  内容
@property (nonatomic, assign) NSTimeInterval animationDuration;         //  动画时间
@property (nonatomic, assign) NSTimeInterval delayTime;                 //  持续时间

- (instancetype)init;

/**
 *  初始化一个 MQMaskController
 *
 *  @param type             类型
 *  @param contentView      内容视图
 *  @param contentCenter    是否位于中心，若不是，以 contentView origin 为准
 */
- (instancetype)initWithType:(MQMaskControllerType)type
             withContentView:(UIView *)contentView
               contentCenter:(BOOL)contentCenter;

/**
 *  初始化一个 MQMaskController
 *
 *  @param type             类型
 *  @param contentView      内容视图
 *  @param contentCenter    是否位于中心，若不是，以 contentView origin 为准
 *  @param delayTime        持续时间
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
