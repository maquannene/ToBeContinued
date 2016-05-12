//
//  ImageTrackCell.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import SDWebImage

protocol ImageTrackCellDelegate: NSObjectProtocol {
    func imageTrackCellDidLongPress(imageTrackCell: ImageTrackCell, gesture: UIGestureRecognizer) -> Void
}

class ImageTrackCell: UICollectionViewCell {
    
    weak var delegate: ImageTrackCellDelegate?
    weak var imageTrack: ImageTrackModel?
    var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var longImageIcon: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 2
            imageView.layer.borderWidth = 0
            imageView.clipsToBounds = true
            imageView.backgroundColor = RGBA(235.0, 235.0, 235.0, 1)
        }
    }
    
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.layer.cornerRadius = 3
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ImageTrackCell.longpressAction(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        let attributes = layoutAttributes as! ImageTrackLayoutAttributes
        longImageIcon.hidden = !attributes.longImage
    }
    
    @objc private func longpressAction(sender: AnyObject) {
        delegate?.imageTrackCellDidLongPress(self, gesture: sender as! UIGestureRecognizer)
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

//  MARK: Public
extension ImageTrackCell {
    
    func configureCell(imageTrack: ImageTrackModel!) -> Void {
        
        self.imageTrack = imageTrack
        
        let captureUrlStr = self.imageTrack?.largeImageFileUrl
        
        imageView.mq_setImageWithURL(NSURL(string: imageTrack.thumbImageFileUrl ?? imageTrack.originImageFileUrl)!,
                                     groupIdentifier: reuseIdentifier,
                                     placeholderImage: nil,
                                     options: .RetryFailed,
                                     progress:
            { [weak self] (receivedSize, expectedSize) -> Void in
                
                guard let strongSelf = self else { return }
                guard captureUrlStr == strongSelf.imageTrack?.thumbImageFileUrl else { return }
                print("当前图片Text:\(imageTrack.text),进度:\(Float(receivedSize) / Float(expectedSize))")
                strongSelf.progressView.hidden = false
                strongSelf.progressView.progress = Float(receivedSize) / Float(expectedSize)
            }, completed: { [weak self] (image, error, cacheType, url) -> Void in
                
                guard let strongSelf = self else { return }
                guard url.absoluteString == strongSelf.imageTrack?.thumbImageFileUrl else { return }  //  回调验证
                guard error == nil else { return }
                strongSelf.progressView.hidden = true
            })
        
        textLabel.text = imageTrack.text
    }
    
}

