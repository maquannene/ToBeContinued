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
    dynamic var createdAt: Date!
    
    dynamic var title: String!
    dynamic var detailContent: String?
    
    convenience init(objectId: String? = UUID().uuidString, identifier: String!, title: String!, detailContent: String?) {
        self.init()
        self.objectId = objectId
        self.identifier = identifier
        self.title = title
        self.detailContent = detailContent
    }
    
    convenience init(model: NoteTrackCacheModel) {
        self.init(objectId: model.objectId, identifier: model.identifier, title: model.title, detailContent: model.detailContent)
    }
    
    func update(_ title: String!, detailContent: String?) {
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
        let object = NoteTrackModel(objectId: objectId, identifier: identifier, title: title, detailContent: detailContent)
        return object
    }
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
}
