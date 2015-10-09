//
//  MQPictureBrowserCell.swift
//  MQPictureBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit
import AVFoundation

protocol MQPictureBrowserCellDelegate: NSObjectProtocol {
    func pictureBrowserCellTap(pictureBrowserCell: MQPictureBrowserCell)
}

class MQPictureBrowserCell: UICollectionViewCell {
    
    lazy var scrollView = UIScrollView()
    lazy var imageView = UIImageView()
    weak var delegate: MQPictureBrowserCellDelegate?
    var doubleTapGesture: UITapGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    var doubleTapGestureLock: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.directionalLockEnabled = true
        scrollView.clipsToBounds = false
        scrollView.delegate = self
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
        super.prepareForReuse()
    }
    
    func tapAction(gesture: UITapGestureRecognizer) {
        delegate?.pictureBrowserCellTap(self)
    }
    
    func dobleTapAction(gesture: UITapGestureRecognizer) {
    
        guard scrollView.maximumZoomScale != 1 else { return }
        guard doubleTapGestureLock == false else { return }
        doubleTapGestureLock = true
        
        let imageActualSize = calculateImageActualRect().size
        
        //  如果当前缩放比是1即正常缩放比
        if scrollView.zoomScale == 1 {
            let cellSize = self.frame.size
            let scale = cellSize.height / imageActualSize.height   //  沾满全屏的缩放比
            let touchPoint = gesture.locationInView(scrollView)
            let w = cellSize.width / scale
            let h = cellSize.height / scale
            let x = touchPoint.x - (w / 2.0)
            let y = touchPoint.y - (h / 2.0)
            //  这个是将指定的区域放大到scrollView.size 的大小
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                //  放大到最大
                self.scrollView.bounds = self.bounds
                self.scrollView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
                self.scrollView.zoomToRect(CGRect(x: x, y: y, width: w, height: h), animated: false)
                }) {
                    self.doubleTapGestureLock = !$0
            }
        }
        else {
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    //  缩小到最小
                    self.scrollView.setZoomScale(1, animated: false)
                    self.scrollView.bounds = CGRect(origin: CGPointZero, size: imageActualSize)
                    self.scrollView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
                }) {
                    self.doubleTapGestureLock = !$0
            }
        }
    }
    
}

//  MARK: Private
extension MQPictureBrowserCell {
    //  当图片等比放大到宽度等于屏幕宽度时，图片在cell中的rect
    func calculateImageActualRect() -> CGRect {
        let imageSize = imageView.image!.size
        //  获取所占区域大小
        let boundingRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat(MAXFLOAT))
        let imageActualSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageSize.width, height:imageSize.height), boundingRect).size
        if self.frame.height < imageActualSize.height {
            return CGRect(origin: CGPointZero, size: imageActualSize)
        }
        else {
            return CGRect(origin: CGPoint(x: 0, y: (self.frame.size.height - imageActualSize.height) / 2), size: imageActualSize)
        }
    }
}

//  MARK: Public
extension MQPictureBrowserCell {
    
    func configure(image: UIImage) {
        imageView.image = image
        let imageActualSize = calculateImageActualRect().size
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

extension MQPictureBrowserCell: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        guard doubleTapGestureLock == false else { return }
        scrollView.bounds.size = CGSizeMake(scrollView.bounds.width, scrollView.contentSize.height)
        scrollView.bounds = CGRect(origin: CGPoint(x: scrollView.bounds.origin.x, y: 0), size: CGSizeMake(scrollView.bounds.width, scrollView.contentSize.height))
    }
    
}
