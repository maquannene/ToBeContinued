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
    var noteTrackVc: NoteTrackViewController?
    
    //  第二部分： 图文迹
    var imageTrackVc: ImageTrackViewController?
    
    //
    var settingVc: SettingViewController?
    
    class func drawerController() -> DrawerController {
        let mainVc = MainMenuViewController()
        let homeVc = HomeViewController()
        let drawerController = DrawerController(center: homeVc, leftDrawerViewController: mainVc, rightDrawerViewController: nil)
        drawerController?.mainVc = mainVc
        drawerController?.homeVc = homeVc
        drawerController?.maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.all
        //  全部特效除过PanningDrawerView
        drawerController?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.all.rawValue & ~MMCloseDrawerGestureMode.panningDrawerView.rawValue))
        drawerController?.mainVc?.delegate = drawerController
        return drawerController!
    }
    
}

extension DrawerController: MainMenuViewControllerDelegate {
    
    func mainMenuViewController(_ mainMenuViewController: MainMenuViewController, operate: MainMenuViewControllerOperate)
    {
        var centerViewController: UIViewController?
        switch operate {
        case .logOut:
            return
        case .home:
            centerViewController = homeVc
        case .noteTrack:
            if noteTrackVc == nil {
                noteTrackVc = UIStoryboard(name: "NoteTrack", bundle: Bundle.main).instantiateInitialViewController() as? NoteTrackViewController
            }
            if let navi = noteTrackVc?.navigationController as UINavigationController? {
                centerViewController = navi
            }
            else {
                centerViewController = UINavigationController(rootViewController: noteTrackVc!)
            }
            
        case .imageTrack:
            if imageTrackVc == nil {
                imageTrackVc = UIStoryboard(name: "ImageTrack", bundle: Bundle.main).instantiateInitialViewController() as? ImageTrackViewController
            }
            centerViewController = imageTrackVc!
            
        case .setting:
            return
        }
        
        if centerViewController == self.centerViewController {
            closeDrawer(animated: true, completion: nil)
        }
        else {
            setCenterView(centerViewController, withFullCloseAnimation: true, completion: { [unowned self] (finish) -> Void in
                self.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
                self.bouncePreview(for: MMDrawerSide.left, distance: 5, completion: { [unowned self] (finish) -> Void in
                    self.openDrawerGestureModeMask = MMOpenDrawerGestureMode.all
                })
            })
        }
    }
    
}
