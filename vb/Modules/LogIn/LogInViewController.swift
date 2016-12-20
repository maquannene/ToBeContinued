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
    case notLogIn                   //  没有登录，没有accessToken等，请登录
    case loading
    case alreadyLogIn               //  有accessToken，并且登陆成功
}

class LogInViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var logInBtn: UIButton!
    
    var logInCompletionHandler: (() -> Void)?
    
    var model: LogInViewModel = LogInViewModel.notLogIn {
        didSet {
            if model == .alreadyLogIn {
                logInBtn.setTitle("Welcome to Back", for: UIControlState())
            }
            else {
                if model == .loading {
                    logInBtn.setTitle("Loading...", for: UIControlState())
                }
                if model == .notLogIn {
                    logInBtn.setTitle("LogIn User Weibo", for: UIControlState())
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
        self.view.backgroundColor = UIColor.brown
        self.backgroundImageView!.image = UIImage(named: "LogInImage")
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 2
        self.userImageView.layer.borderWidth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userInfoManage = UserInfoManange.shareInstance
        if userInfoManage.accessToken != nil && userInfoManage.userID != nil {
            model = LogInViewModel.loading
        }
        else {
            model = LogInViewModel.notLogIn
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //  如果登陆过，就紧接着获取个人信息
        if model == LogInViewModel.loading {
            SVProgressHUD.show(withStatus: "读取个人信息...")
        }
    }

}

//  MARK: Aciton
extension LogInViewController {

    @IBAction func logInAction(_ sender: AnyObject) {
        guard model != LogInViewModel.alreadyLogIn else { return }
        if model == .notLogIn {
            let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
            request.redirectURI = WeiboSDKInfo.RedirectURL
            request.scope = "all"
            WeiboSDK.send(request)
        }
    }
    
    func successLogIn() {
        userImageView.alpha = 0.3
        self.userImageViewCenterY.constant = -50
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.userImageView.alpha = 1
            }) { (finish) -> Void in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [unowned self] () -> Void in
                    self.logInCompletionHandler?()
                }
        }
    }
}

//  MARK: WeiboSDKDelegate
extension LogInViewController: WeiboSDKDelegate {

    //   收到一个来自微博客户端程序的响应。 这里是用weibo 登陆成功后的response 设置userInfo和
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        //  这里的回调 是 晚于 viewWillApper
        //  所以这里要单独进行个人信息获取
        SVProgressHUD.showSuccess(withStatus: "登陆成功")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            SVProgressHUD.show(withStatus: "读取个人信息...")
            UserInfoManange.shareInstance.getUserInfo() { [unowned self] (success, userModel) in
                //  隐藏进度条
                SVProgressHUD.dismiss()
                if success && userModel != nil {
                    self.model = LogInViewModel.alreadyLogIn
                    if let avatar_large = userModel?.avatar_large as String?,
                       let userImageURL = URL(string: avatar_large) {
                        self.userImageView.kf.setImage(with: ImageResource(downloadURL: userImageURL))
                    }
                    self.successLogIn()
                }
            }
        }
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
}



