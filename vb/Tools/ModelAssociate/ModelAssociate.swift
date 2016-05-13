//
//  ModelAssociate.swift
//  vb
//
//  Created by 马权 on 5/6/16.
//  Copyright © 2016 maquan. All rights reserved.
//

protocol ModelExportProtocol {
    associatedtype CloudType
    associatedtype CacheType
    func exportToCloudObject() -> CloudType!
//    static func convertCacheToCloudObject(cacheObject: CacheType) -> CloudType
    func exportToCacheObject() -> CacheType!
//    static func convertCloudToCacheObject(cloudObject: CloudType) -> CacheType
}

protocol CloudModelBase {
    static func uniqueIdentifier() -> String!
}

extension CloudModelBase {
    static func uniqueIdentifier() -> String! {
        return UserInfoManange.shareInstance.uniqueCloudKey! + String(self)
    }
}

protocol CacheModelBase {
    static func uniqueIdentifier() -> String!
    func synced() -> Bool
}

extension CacheModelBase {
    static func uniqueIdentifier() -> String! {
        return UserInfoManange.shareInstance.uniqueCacheKey! + String(self)
    }
    func synced() -> Bool {
        return false
    }
}