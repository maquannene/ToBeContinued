//
//  ImageTrackModel.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVOSCloud

class ImageTrackModel: AVObject, CloudModelBase {
    
    @NSManaged var identifier: String!
    
    @NSManaged var thumbImageFileUrl: String?               //  瀑布流使用的略缩图
    @NSManaged var largeImageFileUrl: String?               //  点开看的大图
    @NSManaged var originImageFileUrl: String!              //  原图
    @NSManaged var thumbImageFileObjectId: String?
    @NSManaged var largeImageFileObjectId: String?
    @NSManaged var originImageFileObjectId: String!
    @NSManaged var imageWidht: NSNumber!
    @NSManaged var imageHeight: NSNumber!
    @NSManaged var text: String?
    
//    convenience init(imageFileUrl: String!, imageFileObjectId: String!, text: String?, imageSize: CGSize!) {
//        self.init(thumbImageFileUrl: imageFileUrl,
//            largeImageFileUrl: imageFileUrl,
//            originImageFileUrl: imageFileUrl,
//            thumbImageFileObjectId: imageFileObjectId,
//            largeImageFileObjectId: imageFileObjectId,
//            originImageFileObjectId: imageFileObjectId,
//            text: text,
//            imageSize: imageSize)
//    }
    
    convenience init(
        objectId: String? = NSUUID().UUIDString,
        identifier: String!,
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
        self.identifier = identifier
        self.thumbImageFileUrl = thumbImageFileUrl ?? originImageFileUrl
        self.largeImageFileUrl = largeImageFileUrl ?? originImageFileUrl
        self.originImageFileUrl = originImageFileUrl
        self.thumbImageFileObjectId = thumbImageFileObjectId ?? originImageFileObjectId
        self.largeImageFileObjectId = largeImageFileObjectId ?? originImageFileObjectId
        self.originImageFileObjectId = originImageFileObjectId
        self.text = text
        self.imageWidht = imageSize.width
        self.imageHeight = imageSize.height
    }
    
    convenience init(model: ImageTrackModel) {
        self.init(objectId: model.objectId,
                  identifier: model.identifier,
                  thumbImageFileUrl: model.thumbImageFileUrl,
                  largeImageFileUrl: model.largeImageFileUrl,
                  originImageFileUrl: model.originImageFileUrl,
                  thumbImageFileObjectId: model.thumbImageFileObjectId,
                  largeImageFileObjectId: model.largeImageFileObjectId,
                  originImageFileObjectId: model.originImageFileObjectId,
                  text: model.text,
                  imageSize: CGSize(width: model.imageWidht.integerValue, height:model.imageHeight.integerValue))
    }
    
    convenience init(cacheModel: ImageTrackCacheModel) {
        self.init(objectId: cacheModel.objectId,
                  identifier: cacheModel.identifier,
                  thumbImageFileUrl: cacheModel.thumbImageFileUrl,
                  largeImageFileUrl: cacheModel.largeImageFileUrl,
                  originImageFileUrl: cacheModel.originImageFileUrl,
                  thumbImageFileObjectId: cacheModel.thumbImageFileObjectId,
                  largeImageFileObjectId: cacheModel.largeImageFileObjectId,
                  originImageFileObjectId: cacheModel.originImageFileObjectId,
                  text: cacheModel.text,
                  imageSize: CGSize(width: cacheModel.imageWidht, height:cacheModel.imageHeight))
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

extension ImageTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "ImageTrackModel"
    }
}

extension ImageTrackModel: NSMutableCopying, NSCopying {
    func mutableCopyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = ImageTrackModel(model: self)
        return noteTrackModel
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let noteTrackModel = ImageTrackModel(model: self)
        return noteTrackModel
    }
}

extension ImageTrackModel: ModelExportProtocol {
    
    typealias CloudType = ImageTrackModel
    typealias CacheType = ImageTrackCacheModel
    
    func exportToCacheObject() -> CacheType! {
        let object = ImageTrackCacheModel(objectId: objectId,
                                          identifier: identifier,
                                          thumbImageFileUrl: thumbImageFileUrl,
                                          largeImageFileUrl: largeImageFileUrl,
                                          originImageFileUrl: originImageFileUrl,
                                          thumbImageFileObjectId: thumbImageFileObjectId,
                                          largeImageFileObjectId: largeImageFileObjectId,
                                          originImageFileObjectId: originImageFileObjectId,
                                          text: text,
                                          imageSize: CGSize(width: imageWidht.integerValue, height:imageHeight.integerValue))
        object.createdAt = createdAt
        return object
    }
    
    func exportToCloudObject() -> CloudType! {
        return self
    }
}

extension ImageTrackModel: ImageTrackCellDataSource, ImageTrackDisplayCellDataSource {
    
    var imageURL: String {
        return thumbImageFileUrl ?? originImageFileUrl
    }
    
    var textStr: String? {
        return text
    }
    
    var thumbImageURL: String {
        return thumbImageFileUrl ?? originImageFileUrl
    }
    
    var originImageURL: String {
        return originImageFileUrl
    }
    
    var imageSize: CGSize {
        return CGSize(width: imageWidht.integerValue, height: imageHeight.integerValue)
    }
}