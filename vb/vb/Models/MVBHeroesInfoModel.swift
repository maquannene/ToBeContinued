
//
//  MVBHeroesInfoModel.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBHeroesInfoModel: NSObject {
    var count: NSNumber!
    var status: NSNumber?
    var heroseModelArray: NSMutableArray?
    var heroesDicArray: NSMutableArray?
    override init() {
        self.count = NSNumber(integer: 0)
        
    }
    
    deinit {
        println(" 英雄信息析构 ")
    }
}

extension MVBHeroesInfoModel {
    internal override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        // make sure this isn't a subclass
        if self !== MVBHeroesInfoModel.self {
            return
        }
        dispatch_once(&Static.token) {
            //        MVBHeroesInfoModel.setupObjectClassInArray { () -> [NSObject : AnyObject]! in
            //            return ["heroesDicArray": "MVBHeroModel"]
            //        }
            MVBHeroesInfoModel.setupIgnoredPropertyNames { () -> [AnyObject]! in
                return ["heroseModelArray"]
            }
            MVBHeroesInfoModel.setupReplacedKeyFromPropertyName { () -> [NSObject : AnyObject]! in
                return ["heroesDicArray": "heroes"]
            }
        }
    }
}