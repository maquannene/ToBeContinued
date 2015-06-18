//
//  MVBUserViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBUserViewController: UIViewController {
    
    var userInformationView: MVBUserView!
    weak var userInformationVC: MVBUserInformationViewController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        let nibs: NSArray =  NSBundle.mainBundle().loadNibNamed("MVBUserView", owner: nil, options: nil)
        userInformationView = nibs[0] as! MVBUserView
        self.view.addSubview(userInformationView)
    }
    
    override func viewDidLoad() {
        userInformationView.frame = CGRectMake(0, 64, self.view.bounds.width, self.view.bounds.height - 64)
        self.configurUserInfo()
    }
    
    deinit {
        println("UserViewController deinit")
    }
}

extension MVBUserViewController {

    @IBAction func userNameAction(sender: AnyObject) {
        self.performSegueWithIdentifier("userInformationVC", sender: sender)
        self.getList()
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
            userInformationView.userImageView.sd_setImageWithURL(NSURL(string: userModel.profile_image_url as String!))
            userInformationView.userBgImageView.sd_setImageWithURL(NSURL(string: userModel.cover_image_phone as String!))
            userInformationView.userNameBtn.setTitle(userModel.name! as String, forState: UIControlState.Normal)
            userInformationView.followsCountBtn.setTitle("粉丝: \(userModel.followers_count!)", forState: UIControlState.Normal)
            userInformationView.friendsCountBtn.setTitle("关注: \(userModel.friends_count!)", forState: UIControlState.Normal)
            userInformationView.statusCountBtn.setTitle("微博: \(userModel.statuses_count!)", forState: UIControlState.Normal)
        }
        else {
            let delegate = MVBAppDelegate.MVBApp()
            delegate.getUserInfo(self, tag: nil)
        }
    }
    func getList() {
        var appDelegate = MVBAppDelegate.MVBApp()
        var search: NSString = "张嘉佳"
        var param: [String: AnyObject] = ["access_token": appDelegate.accessToken!, "q": search.URLEncodedString()]
        WBHttpRequest(URL: "https://api.weibo.com/2/search/suggestions/users.json",
            httpMethod: "GET",
            params: param,
            delegate: self,
            withTag: "https://api.weibo.com/2/search/suggestions/users.json")
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
