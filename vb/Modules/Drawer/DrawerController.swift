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
    var homeVc: MVBHomeViewController?
    
    //  第一部分： 图迹
    var noteTrackVc: MVBNoteTrackViewController?
    
    //  第二部分： 图文迹
    var imageTextTrackVc: MVBImageTextTrackViewController?
    
    //
    var settingVc: MVBSettingViewController?
    
    init() {
        let mainVc = MainMenuViewController()
        let homeVc = MVBHomeViewController()
        super.init(centerViewController: homeVc, leftDrawerViewController: mainVc, rightDrawerViewController: nil)
        maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        //  全部特效除过PanningDrawerView
        closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.All.rawValue & ~MMCloseDrawerGestureMode.PanningDrawerView.rawValue))
        
        mainVc.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
