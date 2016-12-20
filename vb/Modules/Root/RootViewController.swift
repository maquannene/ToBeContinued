//
//  RootViewController.swift
//  vb
//
//  Created by 马权 on 5/4/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import MMDrawerController
import SVProgressHUD
import Kingfisher

class RootViewController: UIViewController {
    
    var drawerVc: DrawerController?
    var logInVc: LogInViewController?
    
    weak var currentVc: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userInfoManage = UserInfoManange.shareInstance
        if userInfoManage.accessToken != nil && userInfoManage.userID != nil {
            drawerVc = DrawerController.drawerController()
            present(drawerVc!, animated: false) {
                self.drawerVc!.open(MMDrawerSide.left, animated: true, completion: nil)
            }
        }
        else {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else { return }
            logInVc = vc
            logInVc?.logInCompletionHandler = { [unowned self] in
                self.logInVc?.dismiss(animated: false) {}
            }
            present(vc, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
    }
    
}

//  MARK: WeiboSDKDelegate
extension RootViewController: WeiboSDKDelegate {
    
    //   收到一个来自微博客户端程序的响应。 这里是用weibo 登陆成功后的response 设置userInfo和
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        guard
            let _response = response as? WBAuthorizeResponse,
            let accessToken = _response.accessToken,
            let userID = _response.userID else { return }
        
        let userInfoManage = UserInfoManange.shareInstance
        userInfoManage.accessToken = accessToken
        userInfoManage.userID = userID
        
        logInVc?.didReceiveWeiboResponse(response!)
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        logInVc?.didReceiveWeiboRequest(request)
    }
    
}


