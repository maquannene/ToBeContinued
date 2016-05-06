//
//  UserInfoManange.swift
//  vb
//
//  Created by 马权 on 5/4/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import Foundation
import PINCache
import MJExtension
import AFNetworking

class UserInfoManange {
    
    static let shareInstance = UserInfoManange()
    
    private init() {}
    
    static var cacheName = "com.maquan.vb.Account"
    
    var userModel: UserModel?
    
    var cache: PINCache = PINCache(name: cacheName)
    
    var thirdLogInIdentifier: String? {
        get {
            return readUserModel(WeiboSDKInfo.LogFromPrefix)
        }
        set {
            updateUserModel(WeiboSDKInfo.LogFromPrefix, value: newValue)
        }
    }
    
    var userID: String? {
        get {
            return readUserModel(WeiboSDKInfo.UserIDKey)
        }
        set {
            updateUserModel(WeiboSDKInfo.UserIDKey, value: newValue)
        }
    }
    
    var accessToken: String? {
        get {
            return readUserModel(WeiboSDKInfo.AccessTokenKey)
        }
        set {
            updateUserModel(WeiboSDKInfo.AccessTokenKey, value: newValue)
        }
    }
    
    func updateUserModel(key: String!, value: String!) {
        if var authorizeInfo = cache.objectForKey(WeiboSDKInfo.AutorizeInfo) as? [String: String] {
            authorizeInfo[key] = value
            cache.setObject(authorizeInfo, forKey: WeiboSDKInfo.AutorizeInfo)
        }
        else {
            var authorizeInfo = Dictionary<String, String>()
            authorizeInfo[key] = value
            cache.setObject(authorizeInfo, forKey: WeiboSDKInfo.AutorizeInfo)
        }
    }
    
    func readUserModel(key: String!) -> String? {
        guard let authorizeInfo = cache.objectForKey(WeiboSDKInfo.AutorizeInfo) as? [String: String] else { return nil }
        return authorizeInfo[key]
    }
    
    var uniqueCloudKey: String? {
        guard let userID = self.userID else { return nil }
        return thirdLogInIdentifier! + "." + userID + "."
    }
    
    var uniqueCacheKey: String? {
        guard let userID = self.userID else { return nil }
        return thirdLogInIdentifier! + "." + userID + "."
    }
    
    func getUserInfo(fromCachePriority: Bool = false, updateCacheIfNeed: Bool = true, completion: ((Bool, UserModel?) -> Void)?) {
        guard self.userID != nil && self.accessToken != nil else { return }
        if fromCachePriority {
            if let userModel = cache.objectForKey(kUserInfoKey) as? UserModel {
                self.userModel = userModel
            }
            completion?(true, self.userModel)
        }
        
        if self.userModel == nil && updateCacheIfNeed {
            let param: [String : AnyObject] = ["access_token": self.accessToken!, "uid": self.userID!]
            let url = "https://api.weibo.com/2/users/show.json"
            AFHTTPSessionManager().GET(url, parameters: param, progress: nil
                , success: { (datatask, response) -> Void in
                    self.setUserInfoWithValue(response)
                    completion?(true, self.userModel)
                }, failure: { (datatask, error) -> Void in
                    completion?(false, nil)
            })
        }
    }
    
    func setUserInfoWithValue(value: AnyObject!) {
        self.userModel = UserModel().mj_setKeyValues(value)
        cache.setObject(self.userModel!, forKey: kUserInfoKey)
    }
    
    func clearUserInfo() {
        accessToken = nil
        userID = nil
        thirdLogInIdentifier = nil
        userModel = nil
        //  移除存储三个唯一值信息的字典
        cache.removeObjectForKey(WeiboSDKInfo.AutorizeInfo)
        //  移除个人信息的字典
        cache.removeObjectForKey(kUserInfoKey)
    }
    
}