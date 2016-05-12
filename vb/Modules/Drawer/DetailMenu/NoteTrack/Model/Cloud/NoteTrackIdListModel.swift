//
//  NoteTrackIdListModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import AVOSCloud
import RealmSwift

//  记录着所有 NoteTrackId 的list 类。通过每个用户的唯一kIdentifier来查找

class NoteTrackIdListModel: AVObject {
    
    @NSManaged var identifier: String!
    @NSManaged var list: [String]!
    
    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
        self.list = [String]()
    }
}

extension NoteTrackIdListModel: AVSubclassing {
    
    static func parseClassName() -> String! {
        return "NoteTrackIdListModel"
    }
}

extension NoteTrackIdListModel: NSCopying, NSMutableCopying {
    
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackIdListModel()
        noteTrackModel.objectId = self.objectId
        noteTrackModel.identifier = self.identifier
        noteTrackModel.list = self.list
        return noteTrackModel
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackIdListModel()
        noteTrackModel.objectId = self.objectId
        noteTrackModel.identifier = self.identifier
        noteTrackModel.list = self.list
        return noteTrackModel
    }
}

extension NoteTrackIdListModel: ModelExportProtocol {
    
    typealias CloudType = NoteTrackIdListModel
    typealias CacheType = NoteTrackIdListCacheModel
    
    func exportToCacheObject() -> CacheType! {
        let object = NoteTrackIdListCacheModel()
        object.objectId = objectId
        object.identifier = identifier
        object.list = list
        return object
    }
    
    func exportToCloudObject() -> CloudType! {
        return self
    }
}


