//
//  RootViewController.swift
//  vb
//
//  Created by 马权 on 5/4/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import MMDrawerController
import SVProgressHUD
import SDWebImage

class RootViewController: UIViewController {
    
    var drawerVc: DrawerController?
    var logInVc: LogInViewController?
    
    weak var currentVc: UIViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let appDataSource = MVBAppDelegate.MVBApp().dataSource
        if appDataSource.accessToken != nil && appDataSource.userID != nil {
            drawerVc = DrawerController()
            presentViewController(drawerVc!, animated: false) {
                self.drawerVc!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            }
        }
        else {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LogInViewController") as? LogInViewController else { return }
            logInVc = vc
            logInVc?.logInCompletionHandler = { [unowned self] in
                self.logInVc?.dismissViewControllerAnimated(false) {}
            }
            presentViewController(vc, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

//  MARK: WeiboSDKDelegate
extension RootViewController: WeiboSDKDelegate {
    
    //   收到一个来自微博客户端程序的响应。 这里是用weibo 登陆成功后的response 设置userInfo和
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        guard
            let _response = response as? WBAuthorizeResponse,
            let accessToken = _response.accessToken,
            let userID = _response.userID else { return }
        
        MVBAppDelegate.MVBApp().dataSource.accessToken = accessToken
        MVBAppDelegate.MVBApp().dataSource.userID = userID
        
        logInVc?.didReceiveWeiboResponse(response!)
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        logInVc?.didReceiveWeiboRequest(request)
    }
    
}


