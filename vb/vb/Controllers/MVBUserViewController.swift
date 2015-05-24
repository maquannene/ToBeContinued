//
//  MVBUserViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBUserViewController: UIViewController {

    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var followsCountBtn: UIButton!
    @IBOutlet weak var friendsCountBtn: UIButton!
    @IBOutlet weak var statusCountBtn: UIButton!
    weak var userInformationVC: MVBUserInformationViewController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.view.sendSubviewToBack(userBgImageView)
    }
    
    override func loadView() {
        let nibs: NSArray =  NSBundle.mainBundle().loadNibNamed("MVBUserView", owner: self, options: nil)
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

extension MVBUserViewController {

    @IBAction func userNameAction(sender: AnyObject) {
        self.performSegueWithIdentifier("userInformationVC", sender: sender)
    }
    
    @IBAction func followsAction(sender: AnyObject) {
        
    }
    
    @IBAction func friendsBtnAction(sender: AnyObject) {
        
    }
    
    @IBAction func statusBtnAction(sender: AnyObject) {
        
    }
}

extension MVBUserViewController {
    func configurUserInfo() {
        if let userModel = MVBAppDelegate.MVBApp().userModel as MVBUserModel? {
            self.userImage.sd_setImageWithURL(NSURL(string: userModel.profile_image_url as String!))
            self.userBgImageView.sd_setImageWithURL(NSURL(string: userModel.cover_image_phone as String!))
            self.userNameBtn.setTitle(userModel.name! as String, forState: UIControlState.Normal)
            self.followsCountBtn.setTitle("粉丝: \(userModel.followers_count!)", forState: UIControlState.Normal)
            self.friendsCountBtn.setTitle("关注: \(userModel.friends_count!)", forState: UIControlState.Normal)
            self.statusCountBtn.setTitle("微博: \(userModel.statuses_count!)", forState: UIControlState.Normal)
        }
        else {
            let delegate = MVBAppDelegate.MVBApp()
            delegate.getUserInfo(self)
        }
    }
}

extension MVBUserViewController: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        var delegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        delegate.userModel = MVBUserModel(keyValues: result)
        self.configurUserInfo()
    }
}
