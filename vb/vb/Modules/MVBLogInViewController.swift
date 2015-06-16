//
//  MVBLogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBLogInViewController: UIViewController {

    @IBOutlet weak var logIn: UIButton!
    var mainViewController: MVBMainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
            logIn.hidden = true
        }
        else {
            logIn.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
            self.performSegueWithIdentifier("LogIn", sender: self)
        }
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = kRedirectURL
        request.scope = "all"
        request.userInfo = ["SSO_From": "SendMessageToWeiboViewController"]
        WeiboSDK.sendRequest(request)
    }
}

extension MVBLogInViewController: WeiboSDKDelegate {
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    //   收到一个来自微博客户端程序的响应。设置userInfo和
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if let _response = response as? WBAuthorizeResponse {
            var authorizeInfo = Dictionary<String, String>()
            if let accessToken = _response.accessToken {
                authorizeInfo[kMVBAccessToken] = accessToken
            }
            else {
                return
            }
            
            if let userID = _response.userID {
                authorizeInfo[kMVBUserID] = userID
            }
            else {
                return
            }
            
            NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBAutorizeInfo)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        logIn.hidden = true
        SVProgressHUD.showSuccessWithStatus("登陆成功", maskType: SVProgressHUDMaskType.Black)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus("读取个人信息...", maskType: SVProgressHUDMaskType.Black)
            MVBAppDelegate.MVBApp().getUserInfo(self, tag: nil)
        }
    }
}

extension MVBLogInViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        MVBAppDelegate.MVBApp().userModel = MVBUserModel(keyValues: result)
        SVProgressHUD.dismiss()
        self.performSegueWithIdentifier("LogIn", sender: self)
    }
}



