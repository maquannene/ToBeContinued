

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
        MVBHeroModel.setupReplacedKeyFromPropertyName { () -> [NSObject : AnyObject]! in
            return ["heroId": "id"]
        }
        MVBHeroModel.setupIgnoredPropertyNames { () -> [AnyObject]! in
            return ["heroImage"]
        }
    }

    func getHeroImage(delegate: MVBHeroModelDelegate?) {
        self.delegate = delegate
        var image: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: self.getHeroImageUrl() as! String))
        image.requestSerializer = AFHTTPRequestSerializer() as AFHTTPRequestSerializer
        image.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
        image.responseSerializer.acceptableContentTypes = ["application/json", "text/json", "text/javascript","text/html", "text/plain", "image/png"]
        image.GET(self.getHeroImageUrl() as! String, parameters: nil, success: { (operation, result) in
            self.heroImage = (result as! UIImage)
            self.delegate?.heroModelHeroImageDidLoad(self)
            }) { (operation, error) in
                println(error)
        }
    }
    func getHeroImageUrl() -> NSString {
        var urlName = self.getUrlName(self.name!)
        return kDota2HeroImageUrl + (urlName as String) + "_" + "lg.png"
    }
    
    func getUrlName(name: NSString) -> NSString {
        var range = name.rangeOfString("npc_dota_hero_")
        return name.substringFromIndex(range.length)
    }
}
