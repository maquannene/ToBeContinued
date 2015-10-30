//
//  MVBImageTextTrackModel.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVOSCloud

class MVBImageTextTrackModel: AVObject {
    
    @NSManaged var thumbImageFileUrl: String!               //  瀑布流使用的略缩图
    @NSManaged var largeImageFileUrl: String!               //  点开看的大图
    @NSManaged var originImageFileUrl: String!              //  原图
    @NSManaged var thumbImageFileObjectId: String!
    @NSManaged var largeImageFileObjectId: String!
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
        thumbImageFileUrl: String?,
        largeImageFileUrl: String?,
        originImageFileUrl: String!,
        thumbImageFileObjectId: String?,
        largeImageFileObjectId: String?,
        originImageFileObjectId: String!,
        text: String?,
        imageSize: CGSize!) {
        self.init()
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
    
//    func update(imageFileUrl: String!, imageFileObjectId: String!, text: String?, imageSize: CGSize!) {
//        //  这个AVObject 中的值必须用这个种setObject:forKey的方法，否者没法存储在云上
//        self.largeImageFileUrl = imageFileUrl
//        self.imageFileObjectId = imageFileObjectId
//        self.text = text
//        self.imageWidht = imageSize.width
//        self.imageHeight = imageSize.height
//        print("123")
//    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

extension MVBImageTextTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackModel"
    }
}
