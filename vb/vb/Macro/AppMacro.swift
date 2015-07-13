
//
//  AppMacro.swift
//  vb
//
//  Created by 马权 on 6/10/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

//  sina sdk
let kMVBSinaSDKAppKey = "1325571405"                                            //  key
let kMVBSinaSDKRedirectURL = "http://api.weibo.com/oauth2/default/html"         //  回调页
let kMVBSinaSDKAutorizeInfo = "kMVBSinaSDKAutorizeInfo"
let kMVBSinaSDKAccessToken = "kMVBSinaSDKAccessToken"
let kMVBSinaSDKUserID = "kMVBSinaSDKUserID"

//  avoscloud sdk
let kMVBAVCloudSDKAppID = "76k3lwtg9xseirgzio0xm20io2pt3zpgq5wn83gp7i08rait"
let kMVBAVCloudSDKAppKey = "gex9aggbbgfhzl7lp85ebs8ogaq8xfw8nyhjcsdkwzl14k9j"

//  userInfoKey
let kMVBUserInfoKey = "kMVBUserInfoKey"

func getMainBundlePath() -> String? {
    return  NSBundle.mainBundle().bundlePath
}

func getScreenSize() -> CGSize! {
    return UIScreen.mainScreen().bounds.size
}

func RGBA(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor! {
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}