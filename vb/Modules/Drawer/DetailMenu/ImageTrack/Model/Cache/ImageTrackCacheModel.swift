//
//  ImageTrackCacheModel.swift
//  vb
//
//  Created by 马权 on 5/10/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import RealmSwift

class ImageTrackCacheModel: Object {

    dynamic var objectId: String!
    dynamic var thumbImageFileUrl: String!               //  瀑布流使用的略缩图
    dynamic var largeImageFileUrl: String!               //  点开看的大图
    dynamic var originImageFileUrl: String!              //  原图
    dynamic var thumbImageFileObjectId: String!
    dynamic var largeImageFileObjectId: String!
    dynamic var originImageFileObjectId: String!
    dynamic var imageWidht: Double = 0.0
    dynamic var imageHeight: Double = 0.0
    dynamic var text: String?
    dynamic var createdAt: NSDate!
 
    convenience init(
        objectId: String = NSUUID().UUIDString,
        thumbImageFileUrl: String?,
        largeImageFileUrl: String?,
        originImageFileUrl: String!,
        thumbImageFileObjectId: String?,
        largeImageFileObjectId: String?,
        originImageFileObjectId: String!,
        text: String?,
        imageSize: CGSize!) {
        self.init()
        self.objectId = objectId
        self.thumbImageFileUrl = thumbImageFileUrl ?? originImageFileUrl
        self.largeImageFileUrl = largeImageFileUrl ?? originImageFileUrl
        self.originImageFileUrl = originImageFileUrl
        self.thumbImageFileObjectId = thumbImageFileObjectId ?? originImageFileObjectId
        self.largeImageFileObjectId = largeImageFileObjectId ?? originImageFileObjectId
        self.originImageFileObjectId = originImageFileObjectId
        self.text = text
        self.imageWidht = Double(imageSize.width)
        self.imageHeight = Double(imageSize.height)
    }
    
    convenience init(model: ImageTrackCacheModel) {
        self.init(objectId: model.objectId,
                  thumbImageFileUrl: model.thumbImageFileUrl,
                  largeImageFileUrl: model.largeImageFileUrl,
                  originImageFileUrl: model.originImageFileUrl,
                  thumbImageFileObjectId: model.thumbImageFileObjectId,
                  largeImageFileObjectId: model.largeImageFileObjectId,
                  originImageFileObjectId: model.originImageFileObjectId,
                  text: model.text,
                  imageSize: CGSize(width: model.imageWidht, height:model.imageHeight))
    }
    
    convenience init(cloudModel: ImageTrackModel) {
        self.init(objectId: cloudModel.objectId,
                  thumbImageFileUrl: cloudModel.thumbImageFileUrl,
                  largeImageFileUrl: cloudModel.largeImageFileUrl,
                  originImageFileUrl: cloudModel.originImageFileUrl,
                  thumbImageFileObjectId: cloudModel.thumbImageFileObjectId,
                  largeImageFileObjectId: cloudModel.largeImageFileObjectId,
                  originImageFileObjectId: cloudModel.originImageFileObjectId,
                  text: cloudModel.text,
                  imageSize: CGSize(width: cloudModel.imageWidht.integerValue, height:cloudModel.imageHeight.integerValue))
    }
    
    override class func primaryKey() -> String? {
        return "objectId"
    }
}

extension ImageTrackCacheModel: ModelExportProtocol {
    
    typealias CacheType = ImageTrackCacheModel
    typealias CloudType = ImageTrackModel
    
    func exportToCloudObject() -> CloudType! {
        let object = ImageTrackModel(cacheModel: self)
        return object
    }
    
    func exportToCacheObject() -> CacheType! {
        return self
    }
}
