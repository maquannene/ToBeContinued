//
//  MVBUserModel.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBUserModel: NSObject {
    var id: NSString?                   //  用户ID
    var name: NSString?                 //  用户昵称
    var profile_image_url: NSString?    //  头像
    var followers_count: NSNumber?
    var friends_count: NSNumber?
    
    var statuses_count: NSNumber?
    var _description: NSString?
//    var province: NSString?             //  省
//    var city: NSString?                 //  市
    var location: NSString?             //  地区
    var cover_image_phone: NSString?    //  背景图片
    var gender: NSString?               //  性别
    var created_at: NSString?           //  注册时间
    
    var status: NSDictionary?           //  最近一条微博
    
    var avatar_large: NSString?         //  大图头像
    var avatar_hd: NSString?            //  高清图像
    
}

extension MVBUserModel {
    internal override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        // make sure this isn't a subclass
        if self !== MVBUserModel.self {
            return
        }
        dispatch_once(&Static.token) {
            //  处理属性和Json key不匹配情况
            MVBUserModel.setupReplacedKeyFromPropertyName { () -> [NSObject : AnyObject]! in
                return ["_description": "description"]
            }
        }
    }
}
