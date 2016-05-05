//
//  DrawerController.swift
//  vb
//
//  Created by 马权 on 5/4/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import MMDrawerController

class DrawerController: MMDrawerController {

    //  左侧主菜单页面
    var mainVc: MainMenuViewController?
    
    //  中间home页面
    var homeVc: HomeViewController?
    
    //  第一部分： 图迹
    var noteTrackVc: N2oteTrackViewController?
    
    //  第二部分： 图文迹
    var imageTextTrackVc: ImageTextTrackViewController?
    
    //
    var settingVc: SettingViewController?
    
    class func drawerController() -> DrawerController {
        let mainVc = MainMenuViewController()
        let homeVc = HomeViewController()
        let drawerController = DrawerController(centerViewController: homeVc, leftDrawerViewController: mainVc, rightDrawerViewController: nil)
        drawerController.mainVc = mainVc
        drawerController.homeVc = homeVc
        drawerController.maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        //  全部特效除过PanningDrawerView
        drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.All.rawValue & ~MMCloseDrawerGestureMode.PanningDrawerView.rawValue))
        drawerController.mainVc?.delegate = drawerController
        return drawerController
    }
    
}

extension DrawerController: MainMenuViewControllerDelegate {
    
    func mainMenuViewController(mainMenuViewController: MainMenuViewController, operate: MainMenuViewControllerOperate)
    {
        var centerViewController: UIViewController?
        switch operate {
        case .LogOut:
            return
        case .Home:
            centerViewController = homeVc
        case .NoteTrack:
            if noteTrackVc == nil {
                noteTrackVc = UIStoryboard(name: "NoteTrack", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! N2oteTrackViewController!
            }
            if let navi = noteTrackVc!.navigationController as UINavigationController? {
                centerViewController = navi
            }
            else {
                centerViewController = UINavigationController(rootViewController: noteTrackVc!)
            }
            
        case .ImageTextTrack:
            if imageTextTrackVc == nil {
                imageTextTrackVc = UIStoryboard(name: "ImageTextTrack", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! ImageTextTrackViewController!
            }
            centerViewController = imageTextTrackVc!
            
        case .Setting:
            return
        }
        
        if centerViewController == self.centerViewController {
            closeDrawerAnimated(true, completion: nil)
        }
        else {
            setCenterViewController(centerViewController, withFullCloseAnimation: true, completion: { [unowned self] (finish) -> Void in
                self.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
                self.bouncePreviewForDrawerSide(MMDrawerSide.Left, distance: 5, completion: { [unowned self] (finish) -> Void in
                    self.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
                })
            })
        }
    }
    
}
