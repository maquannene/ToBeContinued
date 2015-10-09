//
//  MVBImageTextTrackDisplayCell.swift
//  vb
//
//  Created by 马权 on 10/8/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBImageTextTrackDisplayCell: MQPictureBrowserCell {

    var imageTextTrack: MVBImageTextTrackModel!
 
    func configurePictureCell(imageTextTrack: MVBImageTextTrackModel) {
        self.imageTextTrack = imageTextTrack
        super.configure(self.imageTextTrack.imageUrl, imageSize: CGSize(width: imageTextTrack.imageWidht.doubleValue, height: imageTextTrack.imageHeight.doubleValue))
    }
    
}
