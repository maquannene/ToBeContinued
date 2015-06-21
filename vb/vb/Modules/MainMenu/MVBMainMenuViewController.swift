//
//  MVBMainMenuViewController.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SVProgressHUD
import SDWebImage

class MVBMainMenuViewController: UIViewController {
    
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

    @IBAction func logOutAction(sender: AnyObject) {
        UIAlertView.bk_showAlertViewWithTitle("", message: "确定退出", cancelButtonTitle: "取消", otherButtonTitles: ["确定"]) { (alertView, index) -> Void in
            if index == 1 {
                var appDelegate = MVBAppDelegate.MVBApp()
                WeiboSDK.logOutWithToken(appDelegate.accessToken!, delegate: self, withTag: "logOut")
                SVProgressHUD.showWithStatus("正在退出...", maskType: SVProgressHUDMaskType.Black)
            }
        }
    }
    
    func configurUserInfo() {
        if let userModel = MVBAppDelegate.MVBApp().userModel as MVBUserModel? {
            mainMenuView!.headBackgroundImageView.sd_setImageWithURL(NSURL(string: userModel.cover_image_phone as String!))
            mainMenuView!.headImageView.sd_setImageWithURL(NSURL(string: userModel.avatar_large as String!))
            mainMenuView!.nameLabel.text = userModel.name as? String
            mainMenuView!.descriptionLabel.text = userModel._description as? String
            
        }
        else {
            let delegate = MVBAppDelegate.MVBApp()
            delegate.getUserInfo(self, tag: "getUserInfo")
        }
    }
}

extension MVBMainMenuViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        if request.tag == "logOut" {
            MVBAppDelegate.MVBApp().accessToken = nil
            MVBAppDelegate.MVBApp().userID = nil
            SVProgressHUD.dismiss()
            SDImageCache.sharedImageCache().clearDisk()
            SDImageCache.sharedImageCache().clearMemory()
            self.mm_drawerController!.dismissViewControllerAnimated(true, completion: nil)
        }
        if request.tag == "getUserInfo" {
            var delegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
            delegate.userModel = MVBUserModel(keyValues: result)
            self.configurUserInfo()
        }
    }
}
