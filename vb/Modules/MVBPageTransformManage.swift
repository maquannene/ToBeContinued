//
//  MVBPageTransformManage.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController

class MVBPageTransformManage: NSObject {
    
    //  抽屉
    var drawerController: MMDrawerController?
    
    //  左侧主菜单页面
    lazy var mainMenuViewController: MVBMainMenuViewController = MVBMainMenuViewController()
    //  中间home页面
    lazy var homeViewController: MVBHomeViewController = MVBHomeViewController.initWithNavi()
    
    //  第一部分： 图迹
    var noteTrackVc: MVBNoteTrackViewController?
    
    //  第二部分： 图文迹
    var imageTextTrackVc: MVBImageTextTrackViewController?
    
    //
    var settingVc: MVBSettingViewController?
    
    //
    var heroesManageVc: MVBHeroesViewController?
    //  
    var accountManangeVc: MVBAccountManageViewController?
    
    override init()
    {
        super.init()
        //  左侧
        mainMenuViewController.delegate = self
    
        //  抽屉控制器
        drawerController = MMDrawerController(centerViewController: homeViewController.mainNavi!, leftDrawerViewController: mainMenuViewController)
        drawerController!.maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.All.rawValue & ~MMCloseDrawerGestureMode.PanningDrawerView.rawValue))
    }
    
    func displayMainStructureFrom(presentingVc: UIViewController)
    {
        presentingVc.presentViewController(drawerController!, animated: true) {
            self.drawerController!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }
    
    deinit
    {
        print("\(self.dynamicType) deinit\n")
    }
    
}

// MARK: MVBMainMenuViewControllerDelegate
extension MVBPageTransformManage: MVBMainMenuViewControllerDelegate {
    
    func mainMenuViewController(mainMenuViewController: MVBMainMenuViewController, operate: MVBMainMenuViewControllerOperate)
    {
        var centerViewController: UIViewController?
        switch operate {
            case .LogOut:
                return
            case .Home:
                centerViewController = homeViewController.mainNavi!
            case .NoteTrack:
                if noteTrackVc == nil {
                    noteTrackVc = UIStoryboard(name: "MVBNoteTrack", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! MVBNoteTrackViewController!
                }
                if let navi = noteTrackVc!.navigationController as UINavigationController? {
                    centerViewController = navi
                }
                else {
                    centerViewController = UINavigationController(rootViewController: noteTrackVc!)
                }
                
            case .ImageTextTrack:
                if imageTextTrackVc == nil {
                    imageTextTrackVc = UIStoryboard(name: "MVBImageTextTrack", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! MVBImageTextTrackViewController!
                }
                centerViewController = imageTextTrackVc!
            
            case .Setting:
                return
                
            case .HeroesManage:
                if heroesManageVc == nil {
                    heroesManageVc = MVBHeroesViewController()
                }
                centerViewController = heroesManageVc!
                
            case .AccountManage:
                if accountManangeVc == nil {
                    accountManangeVc = MVBAccountManageViewController.initWithNavi()
                }
                centerViewController = accountManangeVc!.mainNavi!
            }
        
        if centerViewController == drawerController!.centerViewController {
            drawerController!.closeDrawerAnimated(true, completion: nil)
        }
        else {
            drawerController!.setCenterViewController(centerViewController, withFullCloseAnimation: true, completion: { [unowned self] (finish) -> Void in
                self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
                self.drawerController!.bouncePreviewForDrawerSide(MMDrawerSide.Left, distance: 5, completion: { (finish) -> Void in
                    self.drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
                })
            })
        }
    }
    
}
