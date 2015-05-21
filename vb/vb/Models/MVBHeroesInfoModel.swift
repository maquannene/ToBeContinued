
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
    var heroesDicArray: NSMutableArray!
    var status: NSNumber!
    var heroseModelArray: NSMutableArray!
    override init() {
        MVBHeroesInfoModel.setupObjectClassInArray { () -> [NSObject : AnyObject]! in
            return ["heroesDicArray": "MVBHeroModel"]
        }
        MVBHeroesInfoModel.setupIgnoredPropertyNames { () -> [AnyObject]! in
            return ["heroseModelArray"]
        }
        MVBHeroesInfoModel.setupReplacedKeyFromPropertyName { () -> [NSObject : AnyObject]! in
            return ["heroesDicArray": "heroes"]
        }
        count = NSNumber(integer: 0)
        status = NSNumber(integer: 0)
        heroesDicArray = NSMutableArray()
        heroseModelArray = NSMutableArray()
    }
}
