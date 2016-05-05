//
//  DrawerVisualStateCustom.Swift
//  vb
//
//  Created by 马权 on 7/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController

// MARK: MMDrawer的自定义动画类，扩展自MMDrawerVisualState
extension MMDrawerVisualState {
    class func MVBCustomDrawerVisualState() -> MMDrawerControllerDrawerVisualStateBlock {
        return { (drawerController: MMDrawerController!, drawerSide: MMDrawerSide, percentVisible: CGFloat) -> Void in
            var sideViewController: UIViewController?
            var scale: CGFloat!
            var scaleTransform: CATransform3D = CATransform3DMakeScale(1, 1, 1);
            var translateTransform: CATransform3D = CATransform3DIdentity
            var maxDistance: CGFloat = 0.0
            var distance: CGFloat = 0.0
            var minScale: CGFloat = 0.0     //  收起时最小缩放比
            
            if drawerSide == MMDrawerSide.None {
                return
            }
            
            if drawerSide == MMDrawerSide.Left {
                sideViewController = drawerController.leftDrawerViewController
                maxDistance = drawerController.maximumLeftDrawerWidth
                distance = maxDistance * percentVisible;
                //  越界
                if distance - maxDistance > 0 {
                    scale = (percentVisible - 1) + 1;
                    translateTransform = CATransform3DMakeTranslation((distance - maxDistance) / 2, 0.0, 0.0);
                }
                else {
                    minScale = maxDistance / drawerController.centerViewController.view.frame.width
                    scale = minScale + percentVisible * (1 - minScale)
                    translateTransform = CATransform3DMakeTranslation(0, 0.0, 0.0);
                }
            }
            if drawerSide == MMDrawerSide.Right {
                sideViewController = drawerController.rightDrawerViewController
                maxDistance = drawerController.maximumRightDrawerWidth
                distance = maxDistance * percentVisible
                //  越界
                if distance - maxDistance > 0 {
                    scale = (percentVisible - 1) * 2 + 1;
                    translateTransform = CATransform3DMakeTranslation(-(distance - maxDistance), 0.0, 0.0);
                }
                else {
                    minScale = maxDistance / drawerController.centerViewController.view.frame.width
                    scale = minScale + percentVisible * (1 - minScale)
                    translateTransform = CATransform3DMakeTranslation(0, 0.0, 0.0);
                }
            }
            scaleTransform = CATransform3DMakeScale(scale, scale, scale);
            sideViewController?.view.layer.transform = CATransform3DConcat(scaleTransform, translateTransform)
            sideViewController?.view.alpha = percentVisible
        }
    }
}
