

//
//  MVBHeroModel.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

let kDota2HeroImageUrl = "http://cdn.dota2.com/apps/dota2/images/heroes/"

protocol MVBHeroModelDelegate {
    func heroModelHeroImageDidLoad(heroModel: MVBHeroModel)
}

class MVBHeroModel: NSObject {
    var heroId: NSNumber?
    var name: NSString?
    var localized_name: NSString?
    var heroImage: UIImage?
    var delegate: MVBHeroModelDelegate?
    override init() {
        //  转json 将id 解析为heroId
        MVBHeroModel.setupReplacedKeyFromPropertyName { () -> [NSObject : AnyObject]! in
            return ["heroId": "id"]
        }
        //  转json忽略 heroImage
        MVBHeroModel.setupIgnoredPropertyNames { () -> [AnyObject]! in
            return ["heroImage"]
        }
    }
    
    //  获取英雄头像图片路径
    func getHeroImageUrl() -> NSString {
        var urlName = self.getUrlName(self.name!)
        return kDota2HeroImageUrl + (urlName as String) + "_" + "lg.png"
    }
    
    //  获取英雄名字
    func getUrlName(name: NSString) -> NSString {
        var range = name.rangeOfString("npc_dota_hero_")
        return name.substringFromIndex(range.length)
    }
}
