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
    @IBOutlet weak var progressView: UIProgressView!
    weak var imageTextTrack: MVBImageTextTrackModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = RGBA(red: 235.0, green: 235.0, blue: 235.0, alpha: 1).CGColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        progressView.layer.cornerRadius = 3
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}

//  MARK: Public
extension MVBImageTextTrackCell {
    func configureCell(imageTextTrack: MVBImageTextTrackModel) -> Void {
        self.imageTextTrack = imageTextTrack
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageUrl)!, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), progress: { [weak self] (receivedSize, expectedSize) -> Void in
            guard let weakSelf = self else { return }
            print("当前图片:\(imageTextTrack.text),进度:\(Float(receivedSize) / Float(expectedSize))")
            weakSelf.progressView.hidden = false
            weakSelf.progressView.progress = Float(receivedSize) / Float(expectedSize)
            }) { [weak self] (image, error, cacheType, url) -> Void in
                guard let weakSelf = self else { return }
                weakSelf.progressView.hidden = true
        }
        textLabel.text = imageTextTrack.text
    }
}

