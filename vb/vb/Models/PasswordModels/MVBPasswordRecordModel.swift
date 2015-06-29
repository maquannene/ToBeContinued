//
//  MVBPasswordRecordModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordModel: AVObject {
    
    var title: String!
    var detailContent: String!
    
    convenience init(title: String, detailContent: String) {
        self.init()
        self.setObject(title, forKey: "title")
        self.setObject(detailContent, forKey: "detailContent")
    }
}

extension MVBPasswordRecordModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBPasswordRecordModel"
    }
}