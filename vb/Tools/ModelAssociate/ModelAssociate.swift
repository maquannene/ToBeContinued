//
//  ModelAssociate.swift
//  vb
//
//  Created by 马权 on 5/6/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class RealmString: Object {
    dynamic var stringValue = ""
}

protocol ModelExportProtocol {
    associatedtype CloudType
    associatedtype CacheType
    func exportToCloudObject() -> CloudType!
    func exportToCacheObject() -> CacheType!
}

