//
//  ImageTrackIdListModel.swift
//  vb
//
//  Created by 马权 on 9/26/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVOSCloud

//  记录着所有 图文迹 的list 类。通过每个用户的唯一kIdentifier来查找

class ImageTrackIdListModel: AVObject, CloudModelBase {
    
    @NSManaged var identifier: String!
    @NSManaged var list: [String]!
    
    convenience init(identifier: String) {
        self.init()
        self.list = [String]()
        self.identifier = identifier
    }
}

extension ImageTrackIdListModel: AVSubclassing {
    
    static func parseClassName() -> String! {
        return "ImageTrackIdListModel"
    }
}

extension ImageTrackIdListModel: ModelExportProtocol {
    
    typealias CacheType = ImageTrackIdListCacheModel
    typealias CloudType = ImageTrackIdListModel
    
    func exportToCloudObject() -> CloudType! {
        return self
    }
    
    func exportToCacheObject() -> CacheType! {
        let object = ImageTrackIdListCacheModel()
        object.objectId = objectId
        object.identifier = identifier
        object.list = list
        return object
    }
}
