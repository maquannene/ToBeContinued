//
//  NoteTrackModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud

class NoteTrackModel: AVObject {
    
    @NSManaged var title: String!
    @NSManaged var detailContent: String?
    
    convenience init(objectId: String! = NSUUID().UUIDString, title: String?, detailContent: String?) {
        self.init()
        self.objectId = objectId
        update(title: title, detailContent: detailContent)
    }
    
    convenience init(model: NoteTrackModel) {
        self.init(objectId: model.objectId, title: model.title, detailContent: model.detailContent)
    }
    
    convenience init(cacheModel: NoteTrackCacheModel) {
        self.init(objectId: cacheModel.objectId, title: cacheModel.title, detailContent: cacheModel.detailContent)
    }
    
    func update(title title: String!, detailContent: String?) {
        self.title = title
        self.detailContent = detailContent
    }
    
    func update(newTrackModel noteTrackModel: NoteTrackModel) {
        self.title = noteTrackModel.title
        self.detailContent = noteTrackModel.detailContent
    }
}

extension NoteTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "NoteTrackModel"
    }
}

extension NoteTrackModel: NSMutableCopying, NSCopying {
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackModel(model: self)
        return noteTrackModel
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackModel(model: self)
        return noteTrackModel
    }
}

extension NoteTrackModel: ModelExportProtocol {
    
    typealias CloudType = NoteTrackModel
    typealias CacheType = NoteTrackCacheModel
    
    func exportToCacheObject() -> CacheType! {
        let object = NoteTrackCacheModel(cloudModel: self)
        object.createdAt = createdAt
        return object
    }
    
    func exportToCloudObject() -> CloudType! {
        return self
    }
}