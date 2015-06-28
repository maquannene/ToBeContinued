//
//  MVBAppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud

@UIApplicationMain
class MVBAppDelegate: UIResponder {

    var window: UIWindow?
    var mainVc: UIViewController!
    var userModel: MVBUserModel?
    
    var userID: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBSinaSDKAutorizeInfo) as? Dictionary {
                return authorizeInfo[kMVBSinaSDKUserID]
            }
            return nil
        }
        set {
            if var authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBSinaSDKAutorizeInfo) as? Dictionary {
                authorizeInfo[kMVBSinaSDKUserID] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBSinaSDKAutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else {
                var authorizeInfo = Dictionary<String, String>()
                authorizeInfo[kMVBSinaSDKUserID] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBSinaSDKAutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var accessToken: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBSinaSDKAutorizeInfo) as? Dictionary {
                return authorizeInfo[kMVBSinaSDKAccessToken]
            }
            return nil
        }
        set {
            if var authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(kMVBSinaSDKAutorizeInfo) as? Dictionary {
                authorizeInfo[kMVBSinaSDKAccessToken] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBSinaSDKAutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else {
                var authorizeInfo = Dictionary<String, String>()
                authorizeInfo[kMVBSinaSDKAccessToken] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: kMVBSinaSDKAutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    class func MVBApp() -> MVBAppDelegate! {
        return UIApplication.sharedApplication().delegate as! MVBAppDelegate
    }
    
    func registThirdSDK() {
        //  sina sdk
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(kMVBSinaSDKAppKey)
        //  AVOSCloud sdk
        MVBPasswordIdListModel.registerSubclass()
        AVOSCloud.setApplicationId(kMVBAVCloudSDKAppID, clientKey: kMVBAVCloudSDKAppKey)
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
        
        self.registThirdSDK()
        
        //  获取用户信息
        self.getUserInfo(self, tag: nil)
        
        //  主视图控制器
        self.mainVc = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MVBLogInViewController") as! MVBLogInViewController)
        
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
    
    func getUserInfo(delegate: WBHttpRequestDelegate?, tag: String?) {
        var appDelegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        if self.userID != nil && self.accessToken != nil {
            if let userData = NSUserDefaults.standardUserDefaults().valueForKey(kMVBUserInfoKey) as? NSData {
                self.userModel = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? MVBUserModel
            }
            else {
                var param: [String: AnyObject] = ["access_token": appDelegate.accessToken!, "uid": appDelegate.userID!]
                WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json",
                    httpMethod: "GET",
                    params: param,
                    delegate: delegate,
                    withTag: tag)
            }
        }
    }
    
    func setUserInfoWithJsonString(jsonString: String!) {
        self.userModel = MVBUserModel(keyValues: jsonString)
        //  归档
        var userData: NSData = NSKeyedArchiver.archivedDataWithRootObject(self.userModel!)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: kMVBUserInfoKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clearUserInfo() {
        MVBAppDelegate.MVBApp().accessToken = nil
        MVBAppDelegate.MVBApp().userID = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kMVBUserInfoKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {

    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithResult result: String!) {
        self.setUserInfoWithJsonString(result)
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


