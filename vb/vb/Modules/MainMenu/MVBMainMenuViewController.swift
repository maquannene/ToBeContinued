//
//  MVBMainMenuViewController.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

enum MVBMainMenuViewControllerOperate: Int {
    case Main
    case PasswordManage
    case HeroesManage
    case AccountManage
    case LogOut
}

protocol MVBMainMenuViewControllerDelegate: NSObjectProtocol {
    func mainMenuViewController(mainMenuViewController: MVBMainMenuViewController, operate: MVBMainMenuViewControllerOperate) -> Void
}

class MVBMainMenuViewController: UIViewController {
    
    weak var delegate: MVBMainMenuViewControllerDelegate?
    weak var mainMenuView: MVBMainMenuView? {
        get {
            return self.view as? MVBMainMenuView
        }
    }
    
    override func loadView() {
        NSBundle.mainBundle().loadNibNamed("MVBMainMenuView", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurUserInfo()
    }
    
    func configurUserInfo() {
        if let userModel = MVBAppDelegate.MVBApp().userModel as MVBUserModel? {
            mainMenuView!.headBackgroundImageView.sd_setImageWithURL(NSURL(string: userModel.cover_image_phone as String!), placeholderImage: nil, options: ~SDWebImageOptions.CacheMemoryOnly)
            mainMenuView!.headImageView.sd_setImageWithURL(NSURL(string: userModel.avatar_large as String!))
            mainMenuView!.nameLabel.text = userModel.name as? String
            mainMenuView!.descriptionLabel.text = userModel._description as? String
        }
        else {
            let delegate = MVBAppDelegate.MVBApp()
            delegate.getUserInfo(self, tag: "getUserInfo")
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

// MARK: buttonAction
extension MVBMainMenuViewController {
    
    @IBAction func logOutAction(sender: AnyObject) {
        UIAlertView.bk_showAlertViewWithTitle("", message: "确定退出", cancelButtonTitle: "取消", otherButtonTitles: ["确定"]) { (alertView, index) -> Void in
            if index == 1 {
                var appDelegate = MVBAppDelegate.MVBApp()
                WeiboSDK.logOutWithToken(appDelegate.accessToken!, delegate: self, withTag: "logOut")
                SVProgressHUD.showWithStatus("正在退出...", maskType: SVProgressHUDMaskType.Black)
            }
        }
    }
    
    @IBAction func backMainAction(sender: AnyObject) {
        delegate!.mainMenuViewController(self, operate: MVBMainMenuViewControllerOperate.Main)
    }
    
    @IBAction func passwordManageAction(sender: AnyObject) {
        delegate!.mainMenuViewController(self, operate: MVBMainMenuViewControllerOperate.PasswordManage)
    }
    
    @IBAction func heroesManageAction(sender: AnyObject) {
        delegate!.mainMenuViewController(self, operate: MVBMainMenuViewControllerOperate.HeroesManage)
    }
    
    @IBAction func accountManageAction(sender: AnyObject) {
        delegate!.mainMenuViewController(self, operate: MVBMainMenuViewControllerOperate.AccountManage)
    }
}

// MARK: WBHttpRequestDelegate
extension MVBMainMenuViewController: WBHttpRequestDelegate {
    
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        if request.tag == "logOut" {
            MVBAppDelegate.MVBApp().clearUserInfo()
            SVProgressHUD.dismiss()
            SDImageCache.sharedImageCache().clearDisk()
            SDImageCache.sharedImageCache().clearMemory()
            self.mm_drawerController!.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate!.mainMenuViewController(self, operate: MVBMainMenuViewControllerOperate.LogOut)
            })
        }
        if request.tag == "getUserInfo" {
            MVBAppDelegate.MVBApp().setUserInfoWithJsonString(result!)
            configurUserInfo()
        }
    }
    
}
