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
    dynamic var identifier: String!
    dynamic var createdAt: NSDate!
    
    dynamic var title: String!
    dynamic var detailContent: String?
    
    convenience init(objectId: String? = NSUUID().UUIDString, identifier: String!, title: String!, detailContent: String?) {
        self.init()
        self.objectId = objectId
        self.identifier = identifier
        self.title = title
        self.detailContent = detailContent
    }
    
    convenience init(model: NoteTrackCacheModel) {
        self.init(objectId: model.objectId, identifier: model.identifier, title: model.title, detailContent: model.detailContent)
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
        let object = NoteTrackCacheModel.convertCacheToCloudObject(self)
        return object
    }
    
    static func convertCacheToCloudObject(cacheObject: CacheType) -> CloudType {
        return NoteTrackModel(objectId: cacheObject.objectId, identifier: cacheObject.identifier, title: cacheObject.title, detailContent: cacheObject.detailContent)
    }
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
    
    static func convertCloudToCacheObject(cloudObject: CloudType) -> CacheType {
        return NoteTrackCacheModel(objectId: cloudObject.objectId, identifier: cloudObject.identifier, title: cloudObject.title, detailContent: cloudObject.detailContent)
    }
}