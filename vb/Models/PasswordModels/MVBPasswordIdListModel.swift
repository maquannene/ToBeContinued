//
//  MVBPasswordIdListModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let kList = "list"
let kIdentifier = "identifier"

class MVBPasswordIdListModel: AVObject {
    
    var identifier: String!
    var list: NSMutableArray!
    
    convenience init(identifier: String) {
        self.init()
        let list = NSMutableArray()
        self[kList] = list
        self[kIdentifier] = identifier
    }
}

extension MVBPasswordIdListModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBPasswordIdListModel"
    }
}