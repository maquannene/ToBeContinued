//
//  MQPictureBrowserCell.swift
//  MQPictureBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

protocol MQPictureBrowserCellDelegate: NSObjectProtocol {
    func pictureBrowserCellTap(pictureBrowserCell: MQPictureBrowserCell)
}

class MQPictureBrowserCell: UICollectionViewCell {
    
    lazy var scrollView = UIScrollView()
    lazy var imageView = UIImageView()
    weak var delegate: MQPictureBrowserCellDelegate?
    var imageSize: CGSize = CGSizeZero
    
    private var doubleTapGesture: UITapGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseConfigure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseConfigure()
    }
    
    func baseConfigure() {
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.directionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.directionalLockEnabled = true
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: "dobleTapAction:")
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "tapAction:")
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        
        tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    }
    
    override func prepareForReuse() {
        scrollView.setZoomScale(1, animated: false)
    }
    
    @objc private func tapAction(gesture: UITapGestureRecognizer) {
        delegate?.pictureBrowserCellTap(self)
    }
    
    @objc private func dobleTapAction(gesture: UITapGestureRecognizer) {
        
        guard scrollView.maximumZoomScale != 1 else { return }
        
        guard imageView.image != nil else { return }
        
        let imageActualSize = calculateImageActualRectInCell(imageView.image!.size).size
        //  如果当前缩放比是1即正常缩放比
        if scrollView.zoomScale == 1 {
            let cellSize = self.frame.size
            let scale = cellSize.height / imageActualSize.height   //  沾满全屏的缩放比
            let touchPoint = gesture.locationInView(self)
            let w = cellSize.width / scale
            let h = cellSize.height / scale
            let x = touchPoint.x - (w / 2.0)
            let y = touchPoint.y - (h / 2.0)
            //  这个是将指定的区域放大到scrollView.size 的大小
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                //  放大到最大
                self.scrollView.zoomToRect(CGRect(x: x, y: y, width: w, height: h), animated: false)
                }) { completed in

            }
        }
        else {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    //  缩小到最小
                    self.scrollView.setZoomScale(1, animated: false)
                }) { completed in
            }
        }
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

//  MARK: Private
extension MQPictureBrowserCell {
    
    //  当图片等比放大到宽度等于屏幕宽度时，图片在cell中的rect
    func calculateImageActualRectInCell(imageSize: CGSize) -> CGRect {
        //  获取所占区域大小
        let boundingRect = CGRect(x: 0, y: 0, width: frame.size.width, height: CGFloat(MAXFLOAT))
        let imageActualSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageSize.width, height:imageSize.height), boundingRect).size
        if self.frame.height < imageActualSize.height {
            return CGRect(origin: CGPoint(x: 0, y: 0), size: imageActualSize)
        }
        else {
            return CGRect(origin: CGPoint(x: 0, y: (frame.size.height - imageActualSize.height) / 2), size: imageActualSize)
        }
    }
    
}

//  MARK: Public
extension MQPictureBrowserCell {
    
    func configure(image: UIImage) {
        imageView.image = image
        self.imageSize = image.size
        defaultConfigure()
    }
    
    func configure(imageUrl: String, imageSize: CGSize) {
        imageView.sd_setImageWithURL(NSURL(string: imageUrl)!)
        self.imageSize = imageSize
        defaultConfigure()
    }
    
    func defaultConfigure() {
        let imageActualSize = calculateImageActualRectInCell(self.imageSize).size
        imageView.frame = CGRect(origin: CGPointZero, size: imageActualSize)
        scrollView.frame = bounds
        scrollView.contentSize = imageActualSize
        //  如果高度超过了屏幕的高度
        if (imageActualSize.height > frame.height) {
            scrollView.maximumZoomScale = 1
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else {
            //  计算出自大缩放比
            scrollView.maximumZoomScale = frame.height / imageActualSize.height
            scrollView.contentInset = UIEdgeInsets(top: (scrollView.h - imageActualSize.height) / 2, left: 0, bottom: (scrollView.h - imageActualSize.height) / 2, right: 0)
        }
    }
    
}

extension MQPictureBrowserCell: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        //  缩放的时候要调整contentInset 很关键
        //  超长图片因为maximumZoomScale = 1所以进不了这个方法。
        scrollView.contentInset = UIEdgeInsets(top: (self.scrollView.h - imageView.frame.height) / 2, left: 0, bottom: (self.scrollView.h - imageView.frame.height) / 2, right: 0)
    }
}
