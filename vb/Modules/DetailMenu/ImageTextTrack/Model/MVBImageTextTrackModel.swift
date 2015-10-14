//
//  MVBImageTextTrackModel.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBImageTextTrackModel: AVObject {
    
    @NSManaged var imageUrl: String!
    @NSManaged var imageWidht: NSNumber!
    @NSManaged var imageHeight: NSNumber!
    @NSManaged var text: String?
    
    convenience init(imageUrl: String!, text: String?, imageSize: CGSize!) {
        self.init()
        update(imageUrl, text: text, imageSize: imageSize)
    }
    
    func update(imageUrl: String!, text: String?, imageSize: CGSize!) {
        //  这个AVObject 中的值必须用这个种setObject:forKey的方法，否者没法存储在云上
        self.imageUrl = imageUrl
        self.text = text
        self.imageWidht = imageSize.width
        self.imageHeight = imageSize.height
        print("123")
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}

extension MVBImageTextTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackModel"
    }
}
