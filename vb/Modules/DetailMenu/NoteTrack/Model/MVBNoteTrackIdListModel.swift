//
//  MVBNoteTrackIdListModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud

//  记录着所有 密码Id 的list 类。通过每个用户的唯一kIdentifier来查找

class MVBNoteTrackIdListModel: AVObject {
    
    @NSManaged var identifier: String!
    @NSManaged var list: NSMutableArray!
    
    convenience init(identifier: String) {
        self.init()
        let list = NSMutableArray()
        self.list = list
        self.identifier = identifier
    }
}

extension MVBNoteTrackIdListModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBNoteTrackIdListModel"
    }
}