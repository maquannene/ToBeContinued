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

    class func allImageTextTrack() -> [MVBImageTextTrackModel] {
        var imageTextTracks = [MVBImageTextTrackModel]()
        for index in 1 ... 13 {
            let imageTextTrack = MVBImageTextTrackModel(image: UIImage(named: "\(index).jpg"), text: "xxxx")
            imageTextTracks.append(imageTextTrack)
        }
        return imageTextTracks
    }
    
    var image: UIImage!
    var text: String!
    
    convenience init(image: UIImage?, text: String?) {
        self.init()
        self.image = image
        self.text = text
//        update(image: image, text: text)
    }
    
//    func update(image image: UIImage?, text: String?) {
//        if image != nil {
//            self.setObject(image, forKey: kImage)
//        }
//        if text != nil {
//            self.setObject(text, forKey: kText)
//        }
//    }
    
}

extension MVBImageTextTrackModel: AVSubclassing {
    static func parseClassName() -> String! {
        return "MVBImageTextTrackModel"
    }
}
