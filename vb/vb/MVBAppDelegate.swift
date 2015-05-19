//
//  MVBAppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

let kMVBAppKey = "1325571405"
let kRedirectURI = "http://api.weibo.com/oauth2/default/html"
let kMVBAutorizeInfo = "kMVBAutorizeInfo"
let kMVBAccessToken = "kMVBAccessToken"
let kMVBUserID = "kMVBUserID"

@UIApplicationMain
class MVBAppDelegate: UIResponder {

    var window: UIWindow?
    var mainVc: UIViewController!
    var userModel: MVBUserModel?
    
    var userID: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBAutorizeInfo) as? Dictionary {
                return authorizeInfo[kMVBUserID]
            }
            return nil
        }
    }
    
    var accessToken: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBAutorizeInfo) as? Dictionary {
                return authorizeInfo[kMVBAccessToken]
            }
            return nil
        }
    }
    
    class func MVBApp() -> MVBAppDelegate! {
        return UIApplication.sharedApplication().delegate as! MVBAppDelegate
    }
    
    func getUserInfo(delegate: WBHttpRequestDelegate) {
        var delegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        if self.userID != nil && self.accessToken != nil {
            var param: [String: AnyObject] = ["access_token": delegate.accessToken!,
                "uid": delegate.userID!]
            WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json",
                          httpMethod: "GET",
                          params: param,
                          delegate: delegate,
                          withTag: "liuliuliu")
        }
    }
}

extension MVBAppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //  debug模式
        WeiboSDK.enableDebugMode(true)
        
        //  使用kMVBAppKey注册应用
        WeiboSDK.registerApp(kMVBAppKey)
        
        //  获取用户信息
        self.getUserInfo(self)
        
        if self.userID == nil || self.accessToken == nil {
            //  主视图控制器
            self.mainVc = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MVBLogInViewController") as! MVBLogInViewController)
        }
        else {
            self.mainVc = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MVBMainViewController") as! MVBMainViewController)
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.grayColor()
        self.window?.rootViewController = self.mainVc
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self.mainVc as! WeiboSDKDelegate)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self.mainVc as! WeiboSDKDelegate)
    }
}

extension MVBAppDelegate: WBHttpRequestDelegate {
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
//        self.userModel = MVBUserModel(data: data, error: nil)
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        self.userModel = MVBUserModel(string: result, error: nil)
    }
}
























