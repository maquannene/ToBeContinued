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
        let userModel: MVBUserModel! = MVBAppDelegate.MVBApp().userModel
        self.userImage.setImageWithURL(NSURL(string: "http://tp3.sinaimg.cn/1697721754/50/5720722434/1"))
        self.userNameLabel.text = userModel.name! as? String
        self.followsCount.text = "粉丝: \(userModel.followers_count!)"
        self.friendsCount.text = "关注: \(userModel.friends_count!)"
        self.statusCount.text = "微博: \(userModel.statuses_count!)"
    }
    @IBAction func exitAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func getUserInfo() {

    }
}
