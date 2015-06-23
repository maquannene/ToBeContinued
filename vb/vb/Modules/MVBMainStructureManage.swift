//
//  MVBMainStructureManage.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController

class MVBMainStructureManage: NSObject {
    
    //  抽屉
    var drawerController: MMDrawerController?
    
    //  左侧主菜单页面
    var mainMenuViewController: MVBMainMenuViewController?
    //  中间主菜单页面
    var mainViewNVC: UINavigationController?
    var mainViewController: MVBMainViewController?
    //
    var heroesManageVc: MVBHeroesViewController?
    //
    var passwordManageVc: MVBPasswordManageViewController?
    
    override init() {
        super.init()
        //  左侧
        mainMenuViewController = MVBMainMenuViewController()
        mainMenuViewController!.delegate = self
        
        //  中间
        mainViewController = MVBMainViewController()
        mainViewNVC = UINavigationController(rootViewController: mainViewController!)
        
        //  抽屉控制器
        drawerController = MMDrawerController(centerViewController: mainViewNVC, leftDrawerViewController: mainMenuViewController)
        drawerController!.maximumLeftDrawerWidth = 260
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All & ~MMCloseDrawerGestureMode.PanningDrawerView
        drawerController!.setDrawerVisualStateBlock { (drawerVc, drawerSide, percentVisible) -> Void in
//            if drawerSide == MMDrawerSide.Left {
                var block: MMDrawerControllerDrawerVisualStateBlock = self.configureDrawerVisualBlock()
                block(drawerVc, drawerSide, percentVisible)
//            }
//            self.configureDrawerVisualBlock()(drawerVc, drawerSide, percentVisible)
        }
    }
    
    func displayMainStructureFrom(#presentingVc: UIViewController) {
        presentingVc.presentViewController(drawerController!, animated: true) { Bool in
            self.drawerController!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }
    
    func configureDrawerVisualBlock() -> MMDrawerControllerDrawerVisualStateBlock {
        return { (drawerController: MMDrawerController!, drawerSide: MMDrawerSide, percentVisible: CGFloat) -> Void in
            var minScale: CGFloat = 0.9
            var scale: CGFloat = minScale + (percentVisible * (1.0 - minScale))
            var scaleTransform: CATransform3D = CATransform3DMakeScale(scale, scale, scale)
            var translateTransform: CATransform3D = CATransform3DIdentity
            var sideViewController: UIViewController?
            var maxDistance: CGFloat = 0.0
            var distance: CGFloat = 0.0
            
            if drawerSide == MMDrawerSide.Left {
                sideViewController = drawerController.leftDrawerViewController!
                maxDistance = drawerController.maximumLeftDrawerWidth
                distance = maxDistance * percentVisible;
                if distance - maxDistance > 0 {
                    translateTransform = CATransform3DMakeTranslation((distance-maxDistance), 0.0, 0.0);
                }
                else {
                    translateTransform = CATransform3DMakeTranslation(0, 0.0, 0.0);
                }
            }
            if drawerSide == MMDrawerSide.Right {
                sideViewController = drawerController.rightDrawerViewController!
                maxDistance = drawerController.maximumRightDrawerWidth
                distance = maxDistance * percentVisible
                if maxDistance - distance > 0 {
                    translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
                }
                else {
                    translateTransform = CATransform3DMakeTranslation(0, 0.0, 0.0);
                }
            }
            sideViewController?.view.layer.transform = CATransform3DConcat(scaleTransform, translateTransform)
            sideViewController?.view.alpha = percentVisible
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

extension MVBMainStructureManage: MVBMainMenuViewControllerDelegate {
    func mainMenuViewController(mainMenuViewController: MVBMainMenuViewController, operate: MVBMainMenuViewControllerOperate) {
        var centerViewController: UIViewController
        switch operate {
        case MVBMainMenuViewControllerOperate.Main:
            centerViewController = mainViewController!.navigationController!
        case MVBMainMenuViewControllerOperate.PasswordManage:
            if passwordManageVc == nil {
                passwordManageVc = MVBPasswordManageViewController()
            }
            centerViewController = passwordManageVc!
        case MVBMainMenuViewControllerOperate.HeroesManage:
            if heroesManageVc == nil {
                heroesManageVc = MVBHeroesViewController()
            }
            centerViewController = heroesManageVc!
        default:
            println()
        }
        if centerViewController == drawerController!.centerViewController {
            drawerController!.closeDrawerAnimated(true) {
                (finsih) -> Void in
            }
        }
        else {
            //  屎一样的写法，不写还不行
            drawerController!.setCenterViewController(centerViewController, withFullCloseAnimation: true) {
                $0
                self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
                self.drawerController!.bouncePreviewForDrawerSide(MMDrawerSide.Left, distance: 5) {
                    $0
                    self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
                }
            }
        }
    }
}





