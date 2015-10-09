//
//  MVBImageTextTrackCell.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

class MVBImageTextTrackCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    var imageTextTrack: MVBImageTextTrackModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
    }
    
}

//  MARK: Public
extension MVBImageTextTrackCell {
    func configureCell(imageTextTrack: MVBImageTextTrackModel) -> Void {
        self.imageTextTrack = imageTextTrack
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageUrl)!)
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageUrl)!, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), progress: { (receivedSize, expectedSize) -> Void in
                print("当前图片:\(imageTextTrack.text),进度:\(Float(receivedSize) / Float(expectedSize))")
            }) { (image, error, cacheType, url) -> Void in
                
        }
        textLabel.text = imageTextTrack.text
    }
}

