//
//  MVBLogInViewController.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBLogInViewController: UIViewController, WBHttpRequestDelegate {

    @IBOutlet weak var logIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
        
        if let userID: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("MVBUserID") {
            if let accessToken: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("MVBAccessToken") {
                var delegate: MVBAppDelegate = UIApplication.sharedApplication().delegate as! MVBAppDelegate
                delegate.userID = userID as! String
                delegate.accessToken = accessToken as! String

            }
        }
        
        let logInBtn = UIButton(frame: CGRectMake(0, 0, 100, 100))
        logInBtn.backgroundColor = UIColor.redColor()
        logInBtn.addTarget(self, action: "getInfo:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logInBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        let request: WBAuthorizeRequest = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = kRedirectURI
        request.scope = "all"
        WeiboSDK.sendRequest(request)
    }
    
    func getInfo(sender: AnyObject) {
        var delegate: MVBAppDelegate = UIApplication.sharedApplication().delegate as! MVBAppDelegate
        var param: [String: AnyObject] = ["access_token": delegate.accessToken!, "uid": delegate.userID!]
//        WBHttpRequest(accessToken: delegate.accessToken! as NSString as String, url: "https://api.weibo.com/2/users/show.json", httpMethod: "GET", params: param as [NSObject : AnyObject], delegate: self, withTag: "123")
        
        WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json", httpMethod: "GET", params: param, delegate: self, withTag: "liuliuliu")
//        WBHttpRequest(forUserProfile: delegate.userID! as String, withAccessToken: delegate.accessToken! as String, andOtherProperties: nil, queue: nil) { (request, result, errot) -> Void in
//            let user:WeiboUser = result as! WeiboUser
//        }        
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        
    }
    
    func request(request: WBHttpRequest!, didFailWithError error: NSError!) {
        
    }
    
    func request(request: WBHttpRequest!, didReceiveResponse response: NSURLResponse!) {
        
    }
}
