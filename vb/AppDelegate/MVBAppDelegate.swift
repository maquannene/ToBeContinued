//
//  MVBAppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

@UIApplicationMain
class MVBAppDelegate: UIResponder {

    var window: UIWindow?
    var mainVc: UIViewController!
    var userModel: MVBUserModel?
    
    var thirdLogInIdentifier: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                return authorizeInfo[MVBWeiboSDK.LogFromWeibo]
            }
            return nil
        }
        set {
            if var authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                authorizeInfo[MVBWeiboSDK.LogFromWeibo] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else {
                var authorizeInfo = Dictionary<String, String>()
                authorizeInfo[MVBWeiboSDK.LogFromWeibo] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var userID: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                return authorizeInfo[MVBWeiboSDK.UserIDKey]
            }
            return nil
        }
        set {
            if var authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                authorizeInfo[MVBWeiboSDK.UserIDKey] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else {
                var authorizeInfo = Dictionary<String, String>()
                authorizeInfo[MVBWeiboSDK.UserIDKey] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    var accessToken: String? {
        get {
            if let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                return authorizeInfo[MVBWeiboSDK.AccessTokenKey]
            }
            return nil
        }
        set {
            if var authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary {
                authorizeInfo[MVBWeiboSDK.AccessTokenKey] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else {
                var authorizeInfo = Dictionary<String, String>()
                authorizeInfo[MVBWeiboSDK.AccessTokenKey] = newValue
                NSUserDefaults.standardUserDefaults().setObject(authorizeInfo, forKey: MVBWeiboSDK.AutorizeInfo)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    //  第三方平台标示 + userID = 存储到云上的唯一标示
    var uniqueCloudKey: String? {
        guard let userID = self.userID else { return nil }
        return thirdLogInIdentifier! + "." + userID + "."
    }
    
    class func MVBApp() -> MVBAppDelegate! {
        return UIApplication.sharedApplication().delegate as! MVBAppDelegate
    }
}

// MARK: Private
extension MVBAppDelegate {
    private func registThirdSDK() {
        //  sina sdk
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(MVBWeiboSDK.AppKey)
        //  AVOSCloud sdk
        MVBPasswordIdListModel.registerSubclass()
        MVBPasswordRecordModel.registerSubclass()
        MVBImageTextTrackIdListModel.registerSubclass()
        MVBImageTextTrackModel.registerSubclass()
        AVOSCloud.setApplicationId(kMVBAVCloudSDKAppID, clientKey: kMVBAVCloudSDKAppKey)
    }
}

extension MVBAppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /**/
        test()
        /**/
        
        let key = String(kCFBundleVersionKey)
        //先去沙盒中取出上次使用的版本号
        _ = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
        //加载程序中的info.plist
        _ = NSBundle.mainBundle().infoDictionary?[key] as! String
        
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        thirdLogInIdentifier = MVBWeiboSDK.LogFromWeibo
        return WeiboSDK.handleOpenURL(url, delegate: self.mainVc as! WeiboSDKDelegate)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self.mainVc as! WeiboSDKDelegate)
    }
}

extension MVBAppDelegate: WBHttpRequestDelegate {
    
    func getUserInfo(delegate: WBHttpRequestDelegate?, tag: String?) {
        let appDelegate: MVBAppDelegate = MVBAppDelegate.MVBApp()
        if self.userID != nil && self.accessToken != nil {
            if let userData = NSUserDefaults.standardUserDefaults().valueForKey(kMVBUserInfoKey) as? NSData {
                self.userModel = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? MVBUserModel
            }
            else {
                let param: [String: AnyObject] = ["access_token": appDelegate.accessToken!, "uid": appDelegate.userID!]
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
        let userData: NSData = NSKeyedArchiver.archivedDataWithRootObject(self.userModel!)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: kMVBUserInfoKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clearUserInfo() {
        MVBAppDelegate.MVBApp().accessToken = nil
        MVBAppDelegate.MVBApp().userID = nil
        MVBAppDelegate.MVBApp().thirdLogInIdentifier = nil
        //  移除存储三个唯一值信息的字典
        NSUserDefaults.standardUserDefaults().removeObjectForKey(MVBWeiboSDK.AutorizeInfo)
        //  移除个人信息的字典
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

extension MVBAppDelegate {
    func test() {
        let x = MVBPasswordRecordCell.self
        let classString = NSStringFromClass(MVBPasswordRecordCell)
        let anyobjectype : AnyObject.Type = NSClassFromString(classString)!
        let nsobjectype : NSObject.Type = anyobjectype as! NSObject.Type
        let rec: AnyObject = nsobjectype.init()
        print(rec)
        
        let y = self.ClassName
        let z = MVBPasswordRecordCell.ClassName
        
    }
}

