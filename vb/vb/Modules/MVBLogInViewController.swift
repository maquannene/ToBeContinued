//
//  MVBLogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBLogInViewController: UIViewController {

    @IBOutlet weak var logInBtn: UIButton!
    var drawerController: MMDrawerController?
    weak var mainViewController: MVBMainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
            logInBtn.hidden = true
        }
        else {
            logInBtn.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var appDelegate = MVBAppDelegate.MVBApp()
        if appDelegate.accessToken != nil && appDelegate.userID != nil {
//            self.performSegueWithIdentifier("LogIn", sender: self)
            self.successLogIn()
        }
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = kRedirectURL
        request.scope = "all"
        request.userInfo = ["SSO_From": "SendMessageToWeiboViewController"]
        WeiboSDK.sendRequest(request)
    }
    
    func successLogIn() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
        mainViewController = mainNavigationController.topViewController as? MVBMainViewController
        
        var leftViewController = UIViewController()
        leftViewController.view.backgroundColor = UIColor.grayColor()
        
        drawerController = MMDrawerController(centerViewController: mainNavigationController, leftDrawerViewController: leftViewController)
        drawerController!.maximumLeftDrawerWidth = 260
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All & ~MMCloseDrawerGestureMode.PanningDrawerView
        drawerController!.setDrawerVisualStateBlock { (drawerVc, drawerSide, percentVisible) -> Void in
            if drawerSide == MMDrawerSide.Left {
                var block: MMDrawerControllerDrawerVisualStateBlock = MMDrawerVisualState.slideAndScaleVisualStateBlock()
                block(drawerVc, drawerSide, percentVisible)
            }
        }
        self.presentViewController(drawerController!, animated: true, completion: nil)
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
        MVBAppDelegate.MVBApp().userModel = MVBUserModel(keyValues: result)
        SVProgressHUD.dismiss()
        self.successLogIn()
//        self.performSegueWithIdentifier("LogIn", sender: self)
    }
}



