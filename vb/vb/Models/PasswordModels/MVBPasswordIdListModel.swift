//
//  MVBPasswordIdListModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordIdListModel: AVObject {
    
    var identifier: String!
    var list: NSMutableArray!
    
    convenience init(identifier: String) {
        self.init()
        var list = NSMutableArray()
        self.setObject(list, forKey: "list")
        self.setObject(identifier, forKey: "identifier")
    }
}

extension MVBPasswordIdListModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBPasswordIdListModel"
    }
}