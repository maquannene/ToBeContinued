//
//  NoteTrackCacheModel.swift
//  vb
//
//  Created by 马权 on 5/6/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class NoteTrackCacheModel: Object, CacheModelBase {
    
    dynamic var objectId: String!
    dynamic var title: String!
    dynamic var detailContent: String!
    
    convenience init(title: String?, detailContent: String?) {
        self.init()
        self.objectId = NSUUID().UUIDString
        self.title = title
        self.detailContent = detailContent
    }
    
    func update(title title: String?, detailContent: String?) {
        self.title = title
        self.detailContent = detailContent
    }
    
    override class func primaryKey() -> String? {
        return "objectId"
    }
}

extension NoteTrackCacheModel: ModelExportProtocol {
    
    typealias CloudType = NoteTrackModel
    typealias CacheType = NoteTrackCacheModel
    
    func exportToCloudObject() -> CloudType! {
        let object = NoteTrackModel()
        object.objectId = objectId
        object.title = title
        object.detailContent = title
        return object
    }
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
}