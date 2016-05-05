
//
//  AppMacro.swift
//  vb
//
//  Created by 马权 on 6/10/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

//  sina sdk

struct WeiboSDKInfo {
    static let AppKey = "1325571405"                                            //  key
    static let RedirectURL = "http://api.weibo.com/oauth2/default/html"         //  回调页
    
    static let AutorizeInfo = "WeiboSDKInfoAutorizeInfo"                         //  认证信息key，保存了下面三项
    static let UserIDKey = "WeiboSDKInfoUserIDKey"                               //  userID
    static let AccessTokenKey = "WeiboSDKInfoAccessTokenKey"                     //  token
    static let LogFromPrefix = "WeiboSDKInfoLogFromWeibo"                         //  微博登陆前缀
}

//  avoscloud sdk
let kAVCloudSDKAppID = "76k3lwtg9xseirgzio0xm20io2pt3zpgq5wn83gp7i08rait"
let kAVCloudSDKAppKey = "gex9aggbbgfhzl7lp85ebs8ogaq8xfw8nyhjcsdkwzl14k9j"

//  userInfoKey
let kUserInfoKey = "MVBUserInfoKey"

func getMainBundlePath() -> String? {
    return  NSBundle.mainBundle().bundlePath
}

func RGBA(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor! {
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}
