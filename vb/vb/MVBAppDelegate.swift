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

@UIApplicationMain
class MVBAppDelegate: UIResponder {

    var window: UIWindow?
    var accessToken: NSString?
    var userID: NSString?
    func MVBApp() -> MVBAppDelegate {
        return UIApplication.sharedApplication().delegate as! MVBAppDelegate
    }
}

extension MVBAppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(kMVBAppKey)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.grayColor()
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MVBLogInViewController") as? UIViewController
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
}

extension MVBAppDelegate: WeiboSDKDelegate {
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if let _response = response as? WBAuthorizeResponse {
            self.accessToken = _response.accessToken
            self.userID = _response.userID
            
            NSUserDefaults.standardUserDefaults().setObject(self.accessToken, forKey: "MVBAccessToken")
            NSUserDefaults.standardUserDefaults().setObject(self.userID, forKey: "MVBUserID")
            NSUserDefaults.standardUserDefaults().synchronize()
            println(_response.userInfo)
            println(_response.accessToken)
            println(_response.userID)
        }
    }
}


























