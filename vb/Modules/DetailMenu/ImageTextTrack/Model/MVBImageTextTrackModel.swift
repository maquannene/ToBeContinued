//
//  MVBImageTextTrackModel.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBImageTextTrackModel: AVObject {
    
    var imageUrl: String!
    var imageWidht: NSNumber!
    var imageHeight: NSNumber!
    var text: String?
    
    convenience init(imageUrl: String!, text: String?, imageSize: CGSize!) {
        self.init()
        update(imageUrl, text: text, imageSize: imageSize)
    }
    
    func update(imageUrl: String!, text: String?, imageSize: CGSize!) {
        //  这个AVObject 中的值必须用这个种setObject:forKey的方法，否者没法存储在云上
        self.setObject(imageUrl, forKey: "imageUrl")
        if text !=  nil {
            self.setObject(text, forKey: "text")
        }
        self.setObject(imageSize.width, forKey: "imageWidht")
        self.setObject(imageSize.height, forKey: "imageHeight")
        print("123")
    }
    
}

extension MVBImageTextTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackModel"
    }
}
