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
    
    convenience init(objectId: String! = UUID().uuidString, identifier: String!, title: String?, detailContent: String?) {
        self.init()
        self.objectId = objectId
        self.identifier = identifier
        update(title, detailContent: detailContent)
    }
    
    convenience init(model: NoteTrackModel) {
        self.init(objectId: model.objectId, identifier: model.identifier, title: model.title, detailContent: model.detailContent)
    }
    
    func update(_ title: String!, detailContent: String?) {
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
    func mutableCopy(with zone: NSZone?) -> Any {
        let noteTrackModel = NoteTrackModel(model: self)
        return noteTrackModel
    }
    
    func copy(with zone: NSZone?) -> Any {
        let noteTrackModel = NoteTrackModel(model: self)
        return noteTrackModel
    }
}

extension NoteTrackModel: ModelExportProtocol {
    
    typealias CloudType = NoteTrackModel
    typealias CacheType = NoteTrackCacheModel
    
    func exportToCacheObject() -> CacheType! {
        let object = NoteTrackCacheModel(objectId: objectId, identifier: identifier, title: title, detailContent: detailContent)
        object.createdAt = createdAt
        return object
    }
    
    func exportToCloudObject() -> CloudType! {
        return self
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
