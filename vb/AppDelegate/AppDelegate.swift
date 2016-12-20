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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 2) {
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        _ = try! Realm()
        
        let key = String(kCFBundleVersionKey)
        //先去沙盒中取出上次使用的版本号
        _ = UserDefaults.standard.object(forKey: key) as? String
        //加载程序中的info.plist
        _ = Bundle.main.infoDictionary?[key] as! String
        
        self.registThirdSDK()
    
        rootVc = RootViewController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.black
        window?.rootViewController = rootVc
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        UserInfoManange.shareInstance.thirdLogInIdentifier = WeiboSDKInfo.LogFromPrefix
        return WeiboSDK.handleOpen(url, delegate: rootVc)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: rootVc)
    }
    
}

// MARK: Private
extension AppDelegate {
    
    fileprivate func registThirdSDK() {
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

