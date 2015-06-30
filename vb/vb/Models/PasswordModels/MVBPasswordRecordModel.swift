//
//  MVBPasswordRecordModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let kTitle = "title"
let kDetailContent = "detailContent"

class MVBPasswordRecordModel: AVObject {
    
    var title: String!
    var detailContent: String!
    
    convenience init(title: String?, detailContent: String?) {
        self.init()
        update(title: title, detailContent: detailContent)
    }
    
    func update(#title: String?, detailContent: String?) {
        if title != nil {
            self.setObject(title, forKey: kTitle)
        }
        if detailContent != nil {
            self.setObject(detailContent, forKey: kDetailContent)
        }
    }
}

extension MVBPasswordRecordModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBPasswordRecordModel"
    }
}