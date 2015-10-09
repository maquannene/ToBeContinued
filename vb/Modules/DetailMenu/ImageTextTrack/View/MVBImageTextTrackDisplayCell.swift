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
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageUrl)!)
        let imageActualSize = calculateImageActualRect(imageSize: CGSize(width: imageTextTrack.imageWidht.doubleValue, height: imageTextTrack.imageHeight.doubleValue)).size
        //  如果高度超过了屏幕的高度
        if (imageActualSize.height > self.frame.height) {
            scrollView.maximumZoomScale = 1
            scrollView.frame = self.bounds
        }
        else {
            //  计算出自大缩放比
            let maxScale = self.frame.height / imageActualSize.height
            scrollView.maximumZoomScale = maxScale
            //  设置滚动
            scrollView.frame =  CGRect(origin: CGPointZero, size: imageActualSize)
        }
        scrollView.minimumZoomScale = 1
        scrollView.contentSize = imageActualSize
        imageView.frame = CGRect(origin: CGPointZero, size: imageActualSize)
        scrollView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
    }
    
}
