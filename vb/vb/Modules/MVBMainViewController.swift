
//
//  MVBMainViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBMainViewController: UIViewController {
    
    var userVC: MVBUserViewController?
    var heroesVC: MVBHeroesViewController?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.yellowColor()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "heroesVC" {
            if heroesVC != nil {
                self.navigationController!.pushViewController(heroesVC!, animated: true)
                return false
            }
            else {
                return true
            }
        }
        if identifier == "userVC" {
            if userVC != nil {
                self.navigationController!.pushViewController(userVC!, animated: true)
                return false
            }
            else {
                return true
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    @IBAction func logOutAction(sender: AnyObject) {
        UIAlertView.bk_showAlertViewWithTitle("", message: "确定退出", cancelButtonTitle: "取消", otherButtonTitles: ["确定"]) { (alertView, index) -> Void in
            if index == 1 {
                var appDelegate = MVBAppDelegate.MVBApp()
                WeiboSDK.logOutWithToken(appDelegate.accessToken!, delegate: self, withTag: nil)
                SVProgressHUD.showWithStatus("正在退出...", maskType: SVProgressHUDMaskType.Black)
            }
        }
    }
    deinit {
    
    }
    
}

extension MVBMainViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        MVBAppDelegate.MVBApp().accessToken = nil
        MVBAppDelegate.MVBApp().userID = nil
        SVProgressHUD.dismiss()
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
