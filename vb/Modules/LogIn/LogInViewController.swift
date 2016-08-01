//
//  LogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SVProgressHUD
import Kingfisher

enum LogInViewModel : Int {
    case NotLogIn                   //  没有登录，没有accessToken等，请登录
    case Loading
    case AlreadyLogIn               //  有accessToken，并且登陆成功
}

class LogInViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var logInBtn: UIButton!
    
    var logInCompletionHandler: (() -> Void)?
    
    var model: LogInViewModel = LogInViewModel.NotLogIn {
        didSet {
            if model == .AlreadyLogIn {
                logInBtn.setTitle("Welcome to Back", forState: UIControlState.Normal)
            }
            else {
                if model == .Loading {
                    logInBtn.setTitle("Loading...", forState: UIControlState.Normal)
                }
                if model == .NotLogIn {
                    logInBtn.setTitle("LogIn User Weibo", forState: UIControlState.Normal)
                }
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
        self.userImageView.layer.cornerRadius = 2
        self.userImageView.layer.borderWidth = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        let userInfoManage = UserInfoManange.shareInstance
        if userInfoManage.accessToken != nil && userInfoManage.userID != nil {
            model = LogInViewModel.Loading
        }
        else {
            model = LogInViewModel.NotLogIn
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //  如果登陆过，就紧接着获取个人信息
        if model == LogInViewModel.Loading {
            SVProgressHUD.showWithStatus("读取个人信息...")
        }
    }

}

//  MARK: Aciton
extension LogInViewController {

    @IBAction func logInAction(sender: AnyObject) {
        guard model != LogInViewModel.AlreadyLogIn else { return }
        if model == .NotLogIn {
            let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
            request.redirectURI = WeiboSDKInfo.RedirectURL
            request.scope = "all"
            WeiboSDK.sendRequest(request)
        }
    }
    
    func successLogIn() {
        userImageView.alpha = 0.3
        self.userImageViewCenterY.constant = -50
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.LayoutSubviews, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.userImageView.alpha = 1
            }) { (finish) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self] () -> Void in
                    self.logInCompletionHandler?()
                }
        }
    }
}

//  MARK: WeiboSDKDelegate
extension LogInViewController: WeiboSDKDelegate {

    //   收到一个来自微博客户端程序的响应。 这里是用weibo 登陆成功后的response 设置userInfo和
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        //  这里的回调 是 晚于 viewWillApper
        //  所以这里要单独进行个人信息获取
        SVProgressHUD.showSuccessWithStatus("登陆成功")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.showWithStatus("读取个人信息...")
            UserInfoManange.shareInstance.getUserInfo() { [unowned self] (success, userModel) in
                //  隐藏进度条
                SVProgressHUD.dismiss()
                if success && userModel != nil {
                    self.model = LogInViewModel.AlreadyLogIn
                    if let avatar_large = userModel?.avatar_large as String?,
                       let userImageURL = NSURL(string: avatar_large) {
                        self.userImageView.kf_setImageWithURL(userImageURL)
                    }
                    self.successLogIn()
                }
            }
        }
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
}



