//
//  MVBImageTextTrackModel.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

let kImage = "image"
let kText = "text"

class MVBImageTextTrackModel: AVObject {

    var image: String!
    var text: String!
    
    convenience init(image: String?, text: String?) {
        self.init()
        update(image: image, text: text)
    }
    
    func update(image image: String?, text: String?) {
        if image != nil {
            self.setObject(image, forKey: kImage)
        }
        if text != nil {
            self.setObject(text, forKey: kText)
        }
    }
    
}

extension MVBImageTextTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackModel"
    }
}
