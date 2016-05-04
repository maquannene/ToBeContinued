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
    
    init() {
        let mainVc = MainMenuViewController()
        let homeVc = MVBHomeViewController()
        super.init(centerViewController: homeVc, leftDrawerViewController: mainVc, rightDrawerViewController: nil)
        maximumLeftDrawerWidth = UIWindow.windowSize().width - 60
        openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        //  全部特效除过PanningDrawerView
        closeDrawerGestureModeMask = MMCloseDrawerGestureMode(rawValue: (MMCloseDrawerGestureMode.All.rawValue & ~MMCloseDrawerGestureMode.PanningDrawerView.rawValue))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
