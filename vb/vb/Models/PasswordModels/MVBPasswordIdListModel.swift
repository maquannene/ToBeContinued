//
//  MVBPasswordIdListModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordIdListModel: AVObject {
    var listIdentifier: String!
    var idList: NSMutableArray!
    
    override init() {
        super.init()
        var idList = NSMutableArray()
        self.setObject(idList, forKey: "idList")
        self.setObject("", forKey: "listIdentifier")
    }
    
    convenience init(listIdentifier identifier: String) {
        self.init()
        self.setObject(identifier, forKey: "listIdentifier")
    }
}

extension MVBPasswordIdListModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBPasswordIdListModel"
    }
}
