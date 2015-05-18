
//
//  MVBMainViewController.swift
//  vb
//
//  Created by 马权 on 5/18/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBMainViewController: UIViewController, WBHttpRequestDelegate {

    override func viewDidLoad() {
        
    }
    
    func getInfo(sender: AnyObject) {
        var delegate: MVBAppDelegate = UIApplication.sharedApplication().delegate as! MVBAppDelegate

        //  填写参数param请求
        var param: [String: AnyObject] = ["access_token": delegate.accessToken!, "uid": delegate.userID!]
        WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json", httpMethod: "GET", params: param, delegate: self, withTag: "liuliuliu")
    }

    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        var userInfo: MVBUser = MVBUser(data: data, error: nil)
    }

    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        var userInfo: MVBUser = MVBUser(string: result, error: nil)
    }

    func request(request: WBHttpRequest!, didFailWithError error: NSError!) {

    }

    func request(request: WBHttpRequest!, didReceiveResponse response: NSURLResponse!) {
        
    }
    
}
