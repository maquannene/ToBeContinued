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
    @NSManaged var detailContent: String!
    
    convenience init(title: String?, detailContent: String?) {
        self.init()
        update(title: title, detailContent: detailContent)
    }
    
    func update(title title: String?, detailContent: String?) {
        self.title = title
        self.detailContent = detailContent
    }
}

extension NoteTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "NoteTrackModel"
    }
}

extension NoteTrackModel: NSMutableCopying, NSCopying {
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackModel()
        noteTrackModel.title = self.title
        noteTrackModel.detailContent = self.detailContent
        noteTrackModel.objectId = self.objectId
        return noteTrackModel
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = NoteTrackModel()
        noteTrackModel.title = self.title
        noteTrackModel.detailContent = self.detailContent
        noteTrackModel.objectId = self.objectId
        return noteTrackModel
    }
}