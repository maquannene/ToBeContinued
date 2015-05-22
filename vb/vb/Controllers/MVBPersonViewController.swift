//
//  MVBPersonViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBPersonViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followsCount: UILabel!
    @IBOutlet weak var friendsCount: UILabel!
    @IBOutlet weak var statusCount: UILabel!
    
    override func loadView() {
        let nibs: NSArray =  NSBundle.mainBundle().loadNibNamed("MVBPersonView", owner: self, options: nil)
        self.view = nibs[0] as! UIView
    }
    
    override func viewDidLoad() {
        self.configurUserInfo()
    }
    
    @IBAction func exitAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}

extension MVBPersonViewController {
    func configurUserInfo() {
        if let userModel = MVBAppDelegate.MVBApp().userModel as MVBUserModel? {
            self.userImage.sd_setImageWithURL(NSURL(string: (userModel.profile_image_url as String?)!))
            self.userNameLabel.text = userModel.name! as? String
            self.followsCount.text = "粉丝: \(userModel.followers_count!)"
            self.friendsCount.text = "关注: \(userModel.friends_count!)"
            self.statusCount.text = "微博: \(userModel.statuses_count!)"
        }
        else {
            let delegate = MVBAppDelegate.MVBApp()
            delegate.getUserInfo(self)
        }
    }
}

extension MVBPersonViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        var delegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        delegate.userModel = MVBUserModel(keyValues: result)
        self.configurUserInfo()
    }
}
