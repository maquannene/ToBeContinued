//
//  NoteTrackIdListCacheModel.Swift
//  vb
//
//  Created by 马权 on 5/6/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class NoteTrackIdListCacheModel: Object, CacheModelBase {
    
    dynamic var objectId: String!
    dynamic var identifier: String!
    var list: [String] {
        get {
            return _list.map { $0.stringValue }
        }
        set {
            _list.removeAll()
            _list.appendContentsOf(newValue.map { RealmString(value: [$0]) })
        }
    }
    
    var _list = List<RealmString>()
    
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

extension NoteTrackIdListCacheModel: ModelExportProtocol {
    
    typealias CloudType = NoteTrackIdListModel
    typealias CacheType = NoteTrackIdListCacheModel
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
    
    func exportToCloudObject() -> CloudType! {
        let object = NoteTrackIdListModel()
        object.objectId = objectId
        object.identifier = identifier
        object.list = list
        return object
    }
}