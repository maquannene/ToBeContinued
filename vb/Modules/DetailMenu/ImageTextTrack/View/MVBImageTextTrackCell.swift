//
//  MVBImageTextTrackCell.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

protocol MVBImageTextTrackCellDelegate: NSObjectProtocol {
    func imageTextTrackCellDidLongPress(imageTextTrackCell: MVBImageTextTrackCell, gesture: UIGestureRecognizer) -> Void
}

class MVBImageTextTrackCell: UICollectionViewCell {
    
    weak var delegate: MVBImageTextTrackCellDelegate?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    var longPressGesture: UILongPressGestureRecognizer!
    weak var imageTextTrack: MVBImageTextTrackModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = RGBA(red: 235.0, green: 235.0, blue: 235.0, alpha: 1).CGColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        progressView.layer.cornerRadius = 3
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "longpressAction:")
        addGestureRecognizer(longPressGesture)
    }
    
    func longpressAction(sender: AnyObject) {
        delegate?.imageTextTrackCellDidLongPress(self, gesture: sender as! UIGestureRecognizer)
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}

//  MARK: Public
extension MVBImageTextTrackCell {
    func configureCell(imageTextTrack: MVBImageTextTrackModel) -> Void {
        self.imageTextTrack = imageTextTrack
        let captureUrlStr = self.imageTextTrack.imageFileUrl
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageFileUrl)!, placeholderImage: nil, options: SDWebImageOptions(rawValue: SDWebImageOptions.RetryFailed.rawValue | 0), progress: { [weak self] (receivedSize, expectedSize) -> Void in
            guard let strongSelf = self else { return }
            guard captureUrlStr == strongSelf.imageTextTrack.imageFileUrl else { return }
            print("当前图片Text:\(imageTextTrack.text),进度:\(Float(receivedSize) / Float(expectedSize))")
            strongSelf.progressView.hidden = false
            strongSelf.progressView.progress = Float(receivedSize) / Float(expectedSize)
            }) { [weak self] (image, error, cacheType, url) -> Void in
                guard let strongSelf = self else { return }
                guard url.absoluteString == strongSelf.imageTextTrack.imageFileUrl else { return }  //  回调验证
                guard error == nil else { return }
                strongSelf.progressView.hidden = true
        }
        textLabel.text = imageTextTrack.text
    }
}

