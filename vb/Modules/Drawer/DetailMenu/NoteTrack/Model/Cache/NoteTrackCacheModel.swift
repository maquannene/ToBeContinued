//
//  NoteTrackCacheModel.swift
//  vb
//
//  Created by 马权 on 5/6/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class NoteTrackCacheModel: Object, CacheModelBase {
    
    dynamic var objectId: String?
    dynamic var title: String!
    dynamic var detailContent: String?
    dynamic var createdAt: NSDate!
    
    convenience init(objectId: String? = NSUUID().UUIDString, title: String!, detailContent: String?) {
        self.init()
        self.objectId = objectId
        self.title = title
        self.detailContent = detailContent
    }
    
    convenience init(model: NoteTrackCacheModel) {
        self.init(objectId: model.objectId, title: model.title, detailContent: model.title)
    }
    
    convenience init(cloudModel: NoteTrackModel) {
        self.init(objectId: cloudModel.objectId, title: cloudModel.title, detailContent: cloudModel.title)
    }
    
    func update(title title: String!, detailContent: String?) {
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
        let object = NoteTrackModel(cacheModel: self)
        return object
    }
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
}