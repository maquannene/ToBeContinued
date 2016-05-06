//
//  AppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    
    var rootVc: RootViewController!
    
}

extension AppDelegate: UIApplicationDelegate {
    
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
    
        rootVc = RootViewController()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.blackColor()
        window?.rootViewController = rootVc
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        UserInfoManange.shareInstance.thirdLogInIdentifier = WeiboSDKInfo.LogFromPrefix
        return WeiboSDK.handleOpenURL(url, delegate: rootVc)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: rootVc)
    }
    
}

// MARK: Private
extension AppDelegate {
    
    private func registThirdSDK() {
        //  sina sdk
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(WeiboSDKInfo.AppKey)
        //  AVOSCloud sdk
        NoteTrackIdListModel.registerSubclass()  //  这几个注册协议必须调用，否则生成不了继承的对象
        NoteTrackModel.registerSubclass()
        ImageTextTrackIdListModel.registerSubclass()
        ImageTextTrackModel.registerSubclass()
        AVOSCloud.setApplicationId(kAVCloudSDKAppID, clientKey: kAVCloudSDKAppKey)
    }
    
}

//extension AppDelegate {
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

extension AppDelegate {
    
    func test() {

    }
    
}

