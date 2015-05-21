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
