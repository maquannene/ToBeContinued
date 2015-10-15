//
//  MVBImageTextTrackDisplayCell.swift
//  vb
//
//  Created by 马权 on 10/8/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBImageTextTrackDisplayCell: MQPictureBrowserCell {

    var imageTextTrack: MVBImageTextTrackModel!
    var progressView: UIProgressView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        progressView = UIProgressView()
        progressView.tintColor = UIColor.grayColor()
        addSubview(progressView)
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        progressView.frame = CGRect(x: 20, y: layoutAttributes.frame.height / 2, width: layoutAttributes.frame.width - 40, height: 20)
    }
    
    func configurePictureCell(imageTextTrack: MVBImageTextTrackModel) {
        self.imageTextTrack = imageTextTrack
        //  这个urlStr 是专门让closure捕获的对比值。
        //  因为同一个imageView可以有很多个获取图片请求，那么请求回调时就要进行对比校验，只有教研正确才能设置进度
        let captureUrlStr = self.imageTextTrack.imageFileUrl
        imageView.sd_setImageWithURL(NSURL(string: imageTextTrack.imageFileUrl)!, placeholderImage: nil, options: SDWebImageOptions(rawValue: SDWebImageOptions.RetryFailed.rawValue | 0), progress: { [weak self] (receivedSize, expectedSize) -> Void in
            guard let strongSelf = self else { return }
            guard captureUrlStr == strongSelf.imageTextTrack.imageFileUrl else { return }
            strongSelf.progressView.hidden = false
            strongSelf.progressView.progress = Float(receivedSize) / Float(expectedSize)
            }) { [weak self] (image, error, cacheType, url) -> Void in
                guard let strongSelf = self else { return }
                guard url.absoluteString == strongSelf.imageTextTrack.imageFileUrl else { return }  //  回调验证
                guard error == nil else { return }
                strongSelf.progressView.hidden = true
        }
        self.imageSize = CGSize(width: imageTextTrack.imageWidht.doubleValue, height: imageTextTrack.imageHeight.doubleValue)
        defaultConfigure()
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}
