//
//  MVBImageTextTrackIdListModel.swift
//  vb
//
//  Created by 马权 on 9/26/15.
//  Copyright © 2015 maquan. All rights reserved.
//

//  记录着所有 图文迹 的list 类。通过每个用户的唯一kIdentifier来查找

class MVBImageTextTrackIdListModel: AVObject {
    
    @NSManaged var identifier: String!
    @NSManaged var list: NSMutableArray!
    
    convenience init(identifier: String) {
        self.init()
        let list = NSMutableArray()
        self.list = list
        self.identifier = identifier
    }
}

extension MVBImageTextTrackIdListModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackIdListModel"
    }
}