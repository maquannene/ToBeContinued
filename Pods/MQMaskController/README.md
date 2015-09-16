# MaskViewController
通用型遮罩层，类似于UIPopoverController，但是更轻量级，
通过自定义contentView内容层，适用于临时气泡弹窗等。

###优势
* 相比UIPopoverController，独有随时随地可以show的优势（类似UIAlertView）不用指定加在某层view上，也不需要从vc present。
* 提供以下四种使用场景类型，根据不同的使用需求可以进行设置。
```objc
typedef NS_ENUM(NSUInteger, MMaskControllerType) {
    MMaskControllerDefault,                     //  1.调用dismiss消失
    MMaskControllerTipDismiss,                  //  2.调用dismiss消失、点击遮罩层消失
    MMaskControllerDelayDismiss,                //  3.调用dismiss消失、延迟时间消失
    MMaskControllerAll                          //  4.调用dismiss消失、点击遮罩层消失、延迟时间消失
};
```
同时提供一下两个常用属性：
```objc
@property (assign, nonatomic) BOOL animation;               //  消失和出现是否有动画.default NO
@property (assign, nonatomic) BOOL contentViewCenter;       //  内容是否显示在中心.default NO
```
* 支持转屏，ios7 和 ios8
转平时触发contentView的layoutsubview，可进行重新布局。

##lifecycle

```objc
//  1.初始化maskController
MMaskController *maskController = [[MMaskController alloc] initMaskController:MMaskControllerDelayDismiss
                                                              withContentView:view
                                                                    animation:YES
                                                                contentCenter:YES
                                                                    delayTime:3];
//  2.设置代理。*注意*：消失回调中 [maskController release], 生命周期结束，类似于popoverController
maskController.delegate = self;
//  3.显示
[maskController show];
```
雕虫小技，且看且不喷。
