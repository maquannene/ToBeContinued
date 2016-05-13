//
//  NoteTrackModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud

class NoteTrackModel: AVObject, CloudModelBase {
    
    @NSManaged var identifier: String!
    
    @NSManaged var title: String!
    @NSManaged var detailContent: String?
    
    convenience init(objectId: String! = NSUUID().UUIDString, identifier: String!, title: String?, detailContent: String?) {
        self.init()
        self.objectId = objectId
        self.identifier = identifier
        update(title: title, detailContent: detailContent)
    }
    
    convenience init(model: NoteTrackModel) {
        self.init(objectId: model.objectId, identifier: model.identifier, title: model.title, detailContent: model.detailContent)
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
        let object = NoteTrackModel.convertCloudToCacheObject(self)
        object.createdAt = createdAt
        return object
    }
    
    static func convertCloudToCacheObject(cloudObject: CloudType) -> CacheType {
        return NoteTrackCacheModel(objectId: cloudObject.objectId, identifier: cloudObject.identifier, title: cloudObject.title, detailContent: cloudObject.detailContent)
    }
    
    func exportToCloudObject() -> CloudType! {
        return self
    }
    
    static func convertCacheToCloudObject(cacheObject: CacheType) -> CloudType {
        return NoteTrackModel(objectId: cacheObject.objectId, identifier: cacheObject.identifier, title: cacheObject.title, detailContent: cacheObject.detailContent)
    }
}

extension NoteTrackModel: NoteTrackCellDataSource, NoteTrackDetailCellDataSource {
    var titleStr: String! {
        return self.title
    }
    
    var detailContentStr: String? {
        return self.detailContent
    }
}