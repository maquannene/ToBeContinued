//
//  MVBLogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SVProgressHUD

enum MVBLogInViewModel : Int {
    case NotLogIn
    case AlreadyLogIn
}

class MVBLogInViewController: UIViewController {

    var structureManage: MVBMainStructureManage?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var logInBtn: UIButton!
    
    var model: MVBLogInViewModel = MVBLogInViewModel.NotLogIn {
        didSet {
            if model == MVBLogInViewModel.AlreadyLogIn {
                logInBtn.setTitle("Welcome to Back", forState: UIControlState.Normal)
            }
            if model == MVBLogInViewModel.NotLogIn {
                logInBtn.setTitle("LogIn User Weibo", forState: UIControlState.Normal)
                //  头像归位
                userImageView.image = nil
                userImageView.alpha = 0
                userImageViewCenterY.constant = 0
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
        self.backgroundImageView!.image = UIImage(named: "LogInImage")
        self.userImageView.clipsToBounds = true
//        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = MVBAppDelegate.MVBApp()
        guard appDelegate.accessToken != nil && appDelegate.userID != nil && appDelegate.userModel != nil else {
            self.model = MVBLogInViewModel.NotLogIn
            return
        }
        self.model = MVBLogInViewModel.AlreadyLogIn
        //  如果开启时是登陆过的，直接加载头像
        userImageView!.sd_setImageWithURL(NSURL(string: MVBAppDelegate.MVBApp().userModel!.avatar_large as String!))
    }
    
    override func viewDidAppear(animated: Bool) {
        let appDelegate = MVBAppDelegate.MVBApp()
        guard appDelegate.accessToken != nil && appDelegate.userID != nil && appDelegate.userModel != nil else { return }
        self.successLogIn()
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        guard model != MVBLogInViewModel.AlreadyLogIn else { return }
        let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = MVBWeiboSDK.RedirectURL
        request.scope = "all"
        WeiboSDK.sendRequest(request)
    }
    
    func successLogIn() {
        userImageView.alpha = 0.3
        self.userImageViewCenterY.constant = -50
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.LayoutSubviews, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.userImageView.alpha = 1
        }) { (finish) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.structureManage = MVBMainStructureManage()
                self.structureManage!.displayMainStructureFrom(self)
            }
        }
    }
}

extension MVBLogInViewController: WeiboSDKDelegate {
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    //   收到一个来自微博客户端程序的响应。设置userInfo和
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        guard
            let _response = response as? WBAuthorizeResponse,
            let accessToken = _response.accessToken,
            let userID = _response.userID else { return }
        
        MVBAppDelegate.MVBApp().accessToken = accessToken
        MVBAppDelegate.MVBApp().userID = userID
        
        self.model = MVBLogInViewModel.AlreadyLogIn
        SVProgressHUD.showSuccessWithStatus("登陆成功")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus("读取个人信息...")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            MVBAppDelegate.MVBApp().getUserInfo(self, tag: nil)
        }
    }
}

extension MVBLogInViewController: WBHttpRequestDelegate {
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        //  设置userModel
        MVBAppDelegate.MVBApp().setUserInfoWithJsonString(result!)
        //  登陆获取信息成功后设置头像
        userImageView!.sd_setImageWithURL(NSURL(string: MVBAppDelegate.MVBApp().userModel!.avatar_large as String!))
        //  隐藏进度条
        SVProgressHUD.dismiss()
        //  成功登陆
        self.successLogIn()
    }
    
}



