//
//  MVBAppDataSource.swift
//  vb
//
//  Created by 马权 on 10/15/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import MJExtension
import AFNetworking

class MVBAppDataSource: NSObject {
    
    var userModel: MVBUserModel?
    
    var thirdLogInIdentifier: String? {
        get {
            guard let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary else { return nil }
            return authorizeInfo[MVBWeiboSDK.LogFromWeibo]
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
            guard let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary else { return nil }
            return authorizeInfo[MVBWeiboSDK.UserIDKey]
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
            guard let authorizeInfo: [String: String] = NSUserDefaults.standardUserDefaults().objectForKey(MVBWeiboSDK.AutorizeInfo) as? Dictionary else { return nil }
            return authorizeInfo[MVBWeiboSDK.AccessTokenKey]
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

    func getUserInfo(delegate: WBHttpRequestDelegate?, tag: String?, fromCache: Bool = false) -> Bool {
        guard self.userID != nil && self.accessToken != nil else { return false }
        if fromCache {
            guard let userData = NSUserDefaults.standardUserDefaults().valueForKey(MVBUserInfoKey) as? NSData else { return false }
            self.userModel = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? MVBUserModel
            return true
        }
        else {
            let param: [String: AnyObject] = ["access_token": self.accessToken!, "uid": self.userID!]
            let _ = WBHttpRequest(URL: "https://api.weibo.com/2/users/show.json", httpMethod: "GET", params: param, delegate: delegate, withTag: tag)
            
            AFHTTPSessionManager().GET("https://api.weibo.com/2/users/show.json", parameters: param, progress: nil
                , success: { (datatask: NSURLSessionDataTask, response) -> Void in
                    print(datatask)
                }, failure: { (datatask, error) -> Void in
                    print(error)
                    //  拿到错误 response 中的数据。
                    let errorData: NSData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as! NSData
                    let json = try? NSJSONSerialization.JSONObjectWithData(errorData, options: [])
                    print(json)
            })
            
            return true
        }
    }
    
    func setUserInfoWithJsonString(jsonString: String!) {
        self.userModel = MVBUserModel().mj_setKeyValues(jsonString)
        //  归档
        let userData: NSData = NSKeyedArchiver.archivedDataWithRootObject(self.userModel!)
        NSUserDefaults.standardUserDefaults().setObject(userData, forKey: MVBUserInfoKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clearUserInfo() {
        accessToken = nil
        userID = nil
        thirdLogInIdentifier = nil
        //  移除存储三个唯一值信息的字典
        NSUserDefaults.standardUserDefaults().removeObjectForKey(MVBWeiboSDK.AutorizeInfo)
        //  移除个人信息的字典
        NSUserDefaults.standardUserDefaults().removeObjectForKey(MVBUserInfoKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
