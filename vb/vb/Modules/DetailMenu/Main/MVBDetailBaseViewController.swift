//
//  MVBDetailBaseViewController.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MMDrawerController

enum MVBDetailBaseViewControllerCustomType {
    case withNavi
}

class MVBDetailBaseViewController: UIViewController {
    
    var mainNavi: UINavigationController?
    
    //  此方法相比在子中写类方法的好处
    convenience init(type: MVBDetailBaseViewControllerCustomType) {
        self.init()
        if type == MVBDetailBaseViewControllerCustomType.withNavi {
            var navi: UINavigationController = UINavigationController(rootViewController: self)
            mainNavi = navi
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        println("\(self.dynamicType) \(__FUNCTION__))")
        //  主页面不出现时，如新push出了一个vc时，mm_drawerController的打开侧边手势要关闭。知道回主页面。
        self.mm_drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("\(self.dynamicType) \(__FUNCTION__))")
        self.mm_drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
    }
}
