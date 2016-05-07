//
//  RealmString.swift
//  vb
//
//  Created by 马权 on 5/7/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class RealmString: Object {
    dynamic var stringValue = ""
    
    override class func primaryKey() -> String? {
        return "stringValue"
    }
}