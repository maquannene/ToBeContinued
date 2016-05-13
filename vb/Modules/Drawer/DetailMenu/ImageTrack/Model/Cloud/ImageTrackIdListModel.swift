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
    @NSManaged var count: Int
    
    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
        self.list = [String]()
        self.count = 0
    }
}

extension ImageTrackIdListModel: AVSubclassing {
    
    static func parseClassName() -> String! {
        return "ImageTrackIdListModel"
    }
}

extension ImageTrackIdListModel: NSCopying, NSMutableCopying {
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let model = ImageTrackIdListModel()
        model.objectId = self.objectId
        model.identifier = self.identifier
        model.list = self.list
        model.count = self.count
        return model
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let model = ImageTrackIdListModel()
        model.objectId = self.objectId
        model.identifier = self.identifier
        model.list = self.list
        model.count = self.count
        return model
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
        object.count = count
        return object
    }
}
