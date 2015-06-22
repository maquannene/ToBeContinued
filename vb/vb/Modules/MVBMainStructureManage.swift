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
        var mainNavigationController: UINavigationController = UINavigationController(rootViewController: mainViewController!)
        
        //  抽屉控制器
        drawerController = MMDrawerController(centerViewController: mainNavigationController, leftDrawerViewController: mainMenuViewController)
        drawerController!.maximumLeftDrawerWidth = 260
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All & ~MMCloseDrawerGestureMode.PanningDrawerView
        drawerController!.setDrawerVisualStateBlock { (drawerVc, drawerSide, percentVisible) -> Void in
            if drawerSide == MMDrawerSide.Left {
                var block: MMDrawerControllerDrawerVisualStateBlock = MMDrawerVisualState.slideAndScaleVisualStateBlock()
                block(drawerVc, drawerSide, percentVisible)
            }
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

extension MVBMainStructureManage: MVBMainMenuViewControllerDelegate {
    func mainMenuViewController(mainMenuViewController: MVBMainMenuViewController, operate: MVBMainMenuViewControllerOperate) {
        switch operate {
        case MVBMainMenuViewControllerOperate.Main:
            drawerController!.setCenterViewController(mainViewController, withFullCloseAnimation: true, completion: { (finish) -> Void in
                
            })
        case MVBMainMenuViewControllerOperate.HeroesManage:
            if heroesManageVc == nil {
                heroesManageVc = MVBHeroesViewController()
            }
            drawerController!.setCenterViewController(heroesManageVc, withFullCloseAnimation: true, completion: { (finish) -> Void in
                
            })
        case MVBMainMenuViewControllerOperate.PasswordManage:
            if passwordManageVc == nil {
                passwordManageVc = MVBPasswordManageViewController()
            }
            drawerController!.setCenterViewController(passwordManageVc, withFullCloseAnimation: true, completion: { (finish) -> Void in
                
            })
        default:
            println()
        }
    }
}





