//
//  MVBAppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

let kMVBAppKey = "1325571405"
let kRedirectURL = "http://api.weibo.com/oauth2/default/html"
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
        var appDelegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        if self.userID != nil && self.accessToken != nil {
            var param: [String: AnyObject] = ["access_token": appDelegate.accessToken!,
                "uid": appDelegate.userID!]
            WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json",
                          httpMethod: "GET",
                          params: param,
                          delegate: delegate,
                          withTag: nil)
        }
    }
}

extension MVBAppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//      self.test()
        
        let key = String(kCFBundleVersionKey)
        //先去沙盒中取出上次使用的版本号
        let lastVersionCode = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
        //加载程序中的info.plist
        let currentVersionCode = NSBundle.mainBundle().infoDictionary?[key] as! String
        
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
        self.userModel = MVBUserModel(keyValues: result)
    }
}


//extension MVBAppDelegate {
//    func test() {
////        var requestOperate: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
////        var param: [String: String] = ["key": "5E09D57E6D09BE20A1DF727134A89871", "language": "zh"]
////        requestOperate.GET("https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=5E09D57E6D09BE20A1DF727134A89871&language=zh_cn", parameters: param, success: { (operation :AFHTTPRequestOperation!, result :AnyObject!) -> Void in
////            println(result)
////            var heroes = Heroes(keyValues: result)
////            
////        }) { (operation, error) -> Void in
////            println(error)
////        }
//        
////        var param: [String: String] = ["Content-Type": "image/png"]
//        
//        var image: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: "http://cdn.dota2.com/apps/dota2/images/heroes/terrorblade_lg.png"))
////        image.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
////        image.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
////        image.responseSerializer.acceptableContentTypes = ["application/json", "text/json", "text/javascript","text/html", "text/plain", "image/png"]
//        image.GET("http://cdn.dota2.com/apps/dota2/images/heroes/terrorblade_lg.png", parameters: nil, success: { (operation, result) -> Void in
//            println(result)
//            var image = result as! UIImage
//        }) { (operation, error) -> Void in
//            println(error)
//        }
//        
//    }
//}





















