//
//  MVBLogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SVProgressHUD

class MVBLogInViewController: UIViewController {

    @IBOutlet weak var logInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
            logInBtn.hidden = true
            self.view.backgroundColor = UIColor.whiteColor()
        }
        else {
            logInBtn.hidden = false
            self.view.backgroundColor = UIColor.brownColor()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
            self.successLogIn()
        }
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = kMVBSinaSDKRedirectURL
        request.scope = "all"
        request.userInfo = ["SSO_From": "SendMessageToWeiboViewController"]
        WeiboSDK.sendRequest(request)
    }
    
    func successLogIn() {
        var structureManage = MVBMainStructureManage()
        structureManage.displayMainStructureFrom(presentingVc: self)
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
                authorizeInfo[kMVBSinaSDKAccessToken] = accessToken
            }
            else {
                return
            }
            
            if let userID = _response.userID {
                authorizeInfo[kMVBSinaSDKUserID] = userID
            }
            else {
                return
            }
            
            NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBSinaSDKAutorizeInfo)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        logInBtn.hidden = true
        SVProgressHUD.showSuccessWithStatus("登陆成功", maskType: SVProgressHUDMaskType.Black)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus("读取个人信息...", maskType: SVProgressHUDMaskType.Black)
            MVBAppDelegate.MVBApp().getUserInfo(self, tag: nil)
        }
    }
}

extension MVBLogInViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        MVBAppDelegate.MVBApp().setUserInfoWithJsonString(result!)
        SVProgressHUD.dismiss()
        self.successLogIn()
    }
}



