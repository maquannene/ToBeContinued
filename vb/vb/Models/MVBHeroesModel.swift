
//
//  MVBHeroesModel.swift
//  vb
//
//  Created by 马权 on 5/20/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBHeroesModel: NSObject {
    var count: NSNumber!
    var heroes: NSMutableArray!
    var status: NSNumber!
    override init() {
        count = NSNumber(integer: 0)
        heroes = NSMutableArray()
        status = NSNumber(integer: 0)

    }
}
