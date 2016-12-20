//
//  UserInfoManange.swift
//  vb
//
//  Created by 马权 on 5/4/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import Foundation
import Track
import MJExtension
import AFNetworking
import RealmSwift

class UserInfoManange {
    
    static let shareInstance = UserInfoManange()
    
    private init() {}
    
    static var cacheName = "com.maquan.vb.Account"
    
    var userModel: UserModel?
    
    var cache: Cache! = Cache(name: cacheName)
    
    let realm: Realm = try! Realm()
    
    var thirdLogInIdentifier: String? {
        get {
            return readUserModel(with: WeiboSDKInfo.LogFromPrefix)
        }
        set {
            updateUserModel(with: WeiboSDKInfo.LogFromPrefix, value: newValue)
        }
    }
    
    var userID: String? {
        get {
            return readUserModel(with: WeiboSDKInfo.UserIDKey)
        }
        set {
            updateUserModel(with: WeiboSDKInfo.UserIDKey, value: newValue)
        }
    }
    
    var accessToken: String? {
        get {
            return readUserModel(with: WeiboSDKInfo.AccessTokenKey)
        }
        set {
            updateUserModel(with: WeiboSDKInfo.AccessTokenKey, value: newValue)
        }
    }
    
    var uniqueCloudKey: String? {
        guard let userID = self.userID else { return nil }
        return thirdLogInIdentifier! + "." + userID + "."
    }
    
    var uniqueCacheKey: String? {
        guard let userID = self.userID else { return nil }
        return thirdLogInIdentifier! + "." + userID + "."
    }
    
    func updateUserModel(with key: String!, value: String!) {
        if var authorizeInfo = cache.object(forKey: WeiboSDKInfo.AutorizeInfo) as? [String: String] {
            authorizeInfo[key] = value
            cache.set(object: authorizeInfo as NSCoding, forKey: WeiboSDKInfo.AutorizeInfo)
        }
        else {
            var authorizeInfo = Dictionary<String, String>()
            authorizeInfo[key] = value
            cache.set(object: authorizeInfo as NSCoding, forKey: WeiboSDKInfo.AutorizeInfo)
        }
    }
    
    func readUserModel(with key: String!) -> String? {
        guard let authorizeInfo = cache.object(forKey: WeiboSDKInfo.AutorizeInfo) as? [String: String] else { return nil }
        return authorizeInfo[key]
    }
    
    func getUserInfo(from cachePriority: Bool = false, updateCacheIfNeed: Bool = true, completion: ((Bool, UserModel?) -> Void)?) {
        guard self.userID != nil && self.accessToken != nil else { return }
        if cachePriority {
            if let userModel = cache.object(forKey: kUserInfoKey) as? UserModel {
                self.userModel = userModel
            }
            completion?(true, self.userModel)
        }
        
        if self.userModel == nil && updateCacheIfNeed {
            let param: [String : AnyObject] = ["access_token": self.accessToken! as AnyObject, "uid": self.userID! as AnyObject]
            let url = "https://api.weibo.com/2/users/show.json"
            AFHTTPSessionManager().get(url, parameters: param, progress: nil
                , success: { (datatask, response) -> Void in
                    self.setUserInfo(with: response as AnyObject!)
                    completion?(true, self.userModel)
                }, failure: { (datatask, error) -> Void in
                    completion?(false, nil)
            })
        }
    }
    
    func setUserInfo(with value: AnyObject!) {
        self.userModel = UserModel().mj_setKeyValues(value)
        cache.set(object: self.userModel!, forKey: kUserInfoKey)
    }
    
    func clear() {
        accessToken = nil
        userID = nil
        thirdLogInIdentifier = nil
        userModel = nil
        // 清理 realm 数据
        do {
            try realm.write {
                self.realm.deleteAll()
            }
        }
        catch {
        
        }
        
        //  移除存储三个唯一值信息的字典
        cache.removeObject(forKey: WeiboSDKInfo.AutorizeInfo)
        //  移除个人信息的字典
        cache.removeObject(forKey: kUserInfoKey)
    }
    
}
