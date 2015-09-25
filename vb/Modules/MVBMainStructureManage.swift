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
    lazy var mainMenuViewController: MVBMainMenuViewController = MVBMainMenuViewController()
    //  中间主菜单页面
    lazy var mainViewController: MVBMainViewController = MVBMainViewController.initWithNavi()
    //
    var heroesManageVc: MVBHeroesViewController?
    //
    var passwordManageVc: MVBPasswordManageViewController?
    //  
    var accountManangeVc: MVBAccountManageViewController?
    
    override init() {
        super.init()
        //  左侧
        mainMenuViewController.delegate = self
    
        //  抽屉控制器
        drawerController = MMDrawerController(centerViewController: mainViewController.mainNavi!, leftDrawerViewController: mainMenuViewController)
        drawerController!.maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.All.rawValue & ~MMCloseDrawerGestureMode.PanningDrawerView.rawValue))
        //  注意这里闭包引起的循环引用问题。self 的 drawerController 的一个 closure 持有self 导致循环引用。使用无主引用解决此问题
        drawerController!.setDrawerVisualStateBlock { (drawerVc, drawerSide, percentVisible) -> Void in
            let block: MMDrawerControllerDrawerVisualStateBlock = MMDrawerVisualState.MVBCustomDrawerVisualState()
            block(drawerVc, drawerSide, percentVisible)
        }
    }
    
    func displayMainStructureFrom(presentingVc: UIViewController) {
        presentingVc.presentViewController(drawerController!, animated: true) { Bool in
            self.drawerController!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
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
            centerViewController = mainViewController.mainNavi!
        case MVBMainMenuViewControllerOperate.PasswordManage:
            if passwordManageVc == nil {
                passwordManageVc = UIStoryboard(name: "MVBPasswordManange", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! MVBPasswordManageViewController!
            }
            if let navi = passwordManageVc!.navigationController as UINavigationController? {
                centerViewController = navi
            }
            else {
                centerViewController = UINavigationController(rootViewController: passwordManageVc!)
            }
        case MVBMainMenuViewControllerOperate.HeroesManage:
            if heroesManageVc == nil {
                heroesManageVc = MVBHeroesViewController()
            }
            centerViewController = heroesManageVc!
        case MVBMainMenuViewControllerOperate.AccountManage:
            if accountManangeVc == nil {
                accountManangeVc = MVBAccountManageViewController.initWithNavi()
            }
            centerViewController = accountManangeVc!.mainNavi!
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
