//
//  ImageTrackIdListCacheModel.swift
//  vb
//
//  Created by 马权 on 5/9/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class ImageTrackId: Object {
    dynamic var id = ""
    override class func primaryKey() -> String? {
        return "id"
    }
}

class ImageTrackIdListCacheModel: Object, CacheModelBase {
    
    dynamic var objectId: String!
    dynamic var identifier: String!
    
    var list: [String] {
        get {
            return _list.map { $0.id }
        }
        set {
            _list.removeAll()
            _list.appendContentsOf(newValue.map { ImageTrackId(value: [$0]) })
        }
    }
    
    var _list = List<ImageTrackId>()
    
    convenience init(identifier: String) {
        self.init()
        self.objectId = NSUUID().UUIDString
        self.list = [String]()
        self.identifier = identifier
    }
    
    override class func primaryKey() -> String? {
        return "objectId"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["list"]
    }
}

extension ImageTrackIdListCacheModel: ModelExportProtocol {
    typealias CloudType = ImageTrackIdListModel
    typealias CacheType = ImageTrackIdListCacheModel
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
    
    func exportToCloudObject() -> CloudType! {
        let object = ImageTrackIdListModel()
        object.objectId = objectId
        object.list = list
        object.identifier = identifier
        return object
    }
}