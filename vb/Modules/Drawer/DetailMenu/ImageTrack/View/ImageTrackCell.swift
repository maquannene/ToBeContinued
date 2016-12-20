//
//  ImageTrackCell.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import Kingfisher
import MKFImageDownloadGroup

protocol ImageTrackCellDelegate: NSObjectProtocol {
    func imageTrackCellDidLongPress(_ imageTrackCell: ImageTrackCell, gesture: UIGestureRecognizer) -> Void
}

protocol ImageTrackCellDataSource: class {
    var imageURL: String { get }
    var textStr: String? { get }
}

class ImageTrackCell: UICollectionViewCell {
    
    weak var delegate: ImageTrackCellDelegate?
    weak var imageTrack: ImageTrackCellDataSource?
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
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let attributes = layoutAttributes as! ImageTrackLayoutAttributes
        longImageIcon.isHidden = !attributes.longImage
    }
    
    @objc func longpressAction(_ sender: AnyObject) {
        delegate?.imageTrackCellDidLongPress(self, gesture: sender as! UIGestureRecognizer)
    }
    
    deinit {
        print("\(type(of: self)) deinit\n", terminator: "")
    }
    
}

//  MARK: Public
extension ImageTrackCell {
    
    func configureCell(_ imageTrack: ImageTrackCellDataSource) -> Void {
        
        self.imageTrack = imageTrack
        
        if let url = URL(string: imageTrack.imageURL) {
            imageView.mkf_setImage(with: url,
                                   identifier: reuseIdentifier,
                                   placeholderImage: nil,
                                   optionsInfo: nil,
                                   progressBlock:
                { [weak self] (receivedSize, totalSize) in
                    
                    guard let strongSelf = self else { return }
                    guard url.absoluteString == strongSelf.imageTrack?.imageURL else { return }
                    print("当前图片Text:\(imageTrack.textStr),进度:\(Float(receivedSize) / Float(totalSize))")
                    strongSelf.progressView.isHidden = false
                    strongSelf.progressView.progress = Float(receivedSize) / Float(totalSize)
                    
                }, completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                    
                    guard let strongSelf = self else { return }
                    guard imageURL?.absoluteString == strongSelf.imageTrack?.imageURL else { return }  //  回调验证
                    guard error == nil else { return }
                    
                    strongSelf.progressView.isHidden = true
                })
        }
        
        textLabel.text = self.imageTrack?.textStr
    }
    
}

