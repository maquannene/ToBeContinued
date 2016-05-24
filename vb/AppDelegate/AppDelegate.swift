//
//  AppDelegate.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    
    var rootVc: RootViewController!
    
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 2) {
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        _ = try! Realm()
        
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
        //  这几个注册协议必须调用，否则生成不了继承的对象
        NoteTrackModel.registerSubclass()
        ImageTrackModel.registerSubclass()
        AVOSCloud.setApplicationId(kAVCloudSDKAppID, clientKey: kAVCloudSDKAppKey)
    }
    
}

extension AppDelegate {
    
    func test() {

    }
    
}

