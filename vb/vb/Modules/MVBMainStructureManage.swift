//
//  MVBMainStructureManage.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBMainStructureManage: NSObject {
    
    //  抽屉
    var drawerController: MMDrawerController?
    
    //  左侧主菜单页面
    var mainMenuViewController: MVBMainMenuViewController?
    //  中间主菜单页面
    var mainViewController: MVBMainViewController?
    
    //
    var heroesManageVc: MVBHeroesViewController?
    //
    var passwordManageVc: MVBPasswordManageViewController?
    //  
    var accountManangeVc: MVBAccountManageViewController?
    
    override init() {
        super.init()
        //  左侧
        mainMenuViewController = MVBMainMenuViewController()
        mainMenuViewController!.delegate = self
        
        //  中间
        mainViewController = MVBMainViewController(type: MVBDetailBaseViewControllerCustomType.withNavi)
        
        //  抽屉控制器
        drawerController = MMDrawerController(centerViewController: mainViewController!.mainNavi!, leftDrawerViewController: mainMenuViewController)
        drawerController!.maximumLeftDrawerWidth = 260
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All & ~MMCloseDrawerGestureMode.PanningDrawerView
        //  注意这里闭包引起的循环引用问题。self 的 drawerController 的一个 closure 持有self 导致循环引用。使用无主引用解决此问题
        drawerController!.setDrawerVisualStateBlock { [unowned self] (drawerVc, drawerSide, percentVisible) -> Void in
            var block: MMDrawerControllerDrawerVisualStateBlock = self.configureDrawerVisualBlock()
            block(drawerVc, drawerSide, percentVisible)
        }
    }
    
    func displayMainStructureFrom(#presentingVc: UIViewController) {
        presentingVc.presentViewController(drawerController!, animated: true) { Bool in
            self.drawerController!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

// MARK: MVBMainMenuViewControllerDelegate
extension MVBMainStructureManage: MVBMainMenuViewControllerDelegate {
    func mainMenuViewController(mainMenuViewController: MVBMainMenuViewController, operate: MVBMainMenuViewControllerOperate) {
        var centerViewController: UIViewController
        switch operate {
        case MVBMainMenuViewControllerOperate.LogOut:
            return
        case MVBMainMenuViewControllerOperate.Main:
            centerViewController = mainViewController!.mainNavi!
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
        case MVBMainMenuViewControllerOperate.AccountManage:
            if accountManangeVc == nil {
                accountManangeVc = MVBAccountManageViewController(type: MVBDetailBaseViewControllerCustomType.withNavi)
            }
            centerViewController = accountManangeVc!
        default:
            println()
        }
        if centerViewController == drawerController!.centerViewController {
            drawerController!.closeDrawerAnimated(true) {
                (finsih) -> Void in
            }
        }
        else {
            drawerController!.setCenterViewController(centerViewController, withFullCloseAnimation: true, completion: { (finish) -> Void in
                self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
                self.drawerController!.bouncePreviewForDrawerSide(MMDrawerSide.Left, distance: 5, completion: { (finish) -> Void in
                    self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
                })
            })
        }
    }
}

// MARK: Private
extension MVBMainStructureManage {
    private func configureDrawerVisualBlock() -> MMDrawerControllerDrawerVisualStateBlock {
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
