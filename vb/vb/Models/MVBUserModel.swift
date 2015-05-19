//
//  MVBUserModel.swift
//  vb
//
//  Created by 马权 on 5/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBUserModel: JSONModel {
    var id: NSString?                   //  用户ID
    var name: NSString?                 //  用户昵称
    var profile_image_url: NSString?    //  头像
    var followers_count: NSNumber?
    var friends_count: NSNumber?
    var statuses_count: NSNumber?
}
