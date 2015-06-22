//
//  MVBMainStructureManage.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController

class MVBMainStructureManage: NSObject {
    
    var drawerController: MMDrawerController?
    var mainMenuViewController: MVBMainMenuViewController?
    var mainViewController: MVBMainViewController?
    
    override init() {
        
        //  左侧
        mainMenuViewController = MVBMainMenuViewController()
        
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
    
    func acquireViewController() -> MMDrawerController! {
        return drawerController!
    }
}
