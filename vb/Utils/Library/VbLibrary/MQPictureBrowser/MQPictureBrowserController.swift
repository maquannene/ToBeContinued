//
//  MQPictureBrowserController.swift
//  MQPictureBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

@objc protocol MQPictureBrowserControllerDataSource: NSObjectProtocol {
    optional func pictureBrowserController(controller: MQPictureBrowserController, willShowPictureFromImageViewAtIndex index: Int ) -> UIImageView
    optional func pictureBrowserController(controller: MQPictureBrowserController, willHidePictureToImageViewAtIndex index: Int) -> UIImageView
    func numberOfItemsInPictureBrowserController(controller: MQPictureBrowserController) -> Int
    func pictureBrowserController(controller: MQPictureBrowserController, cellForItemAtIndex index: Int) -> MQPictureBrowserCell
}

class MQPictureBrowserController: UIViewController {

    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    weak var dataSource: MQPictureBrowserControllerDataSource!
    
    lazy var tmpImageView = UIImageView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionViewFlowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionViewFlowLayout.itemSize = self.view.frame.size
        
        collectionView.frame = self.view.bounds
        collectionView.pagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //  轨迹动画临时imageView
        view.addSubview(tmpImageView)
    }
    
}

//  MARK: Public
extension MQPictureBrowserController {
    
    func presentFromViewController(viewController: UIViewController!, atIndexPicture index: Int = 0) {
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        viewController.presentViewController(self, animated: false) {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
            //  如果是有动画的
            if let imageView = self.dataSource.pictureBrowserController?(self, willShowPictureFromImageViewAtIndex: index) as UIImageView? {
                self.tmpImageView.hidden = false
                self.tmpImageView.image = imageView.image
                let beginRect = self.view.convertRect(imageView.frame, fromView: imageView.superview)
                self.tmpImageView.frame = beginRect
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    let cell = self.collectionView(self.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! MQPictureBrowserCell
                    let imageActualRect = cell.calculateImageActualRect()
                    var endRect = self.view.convertRect(imageActualRect, fromView: cell)
                    endRect.origin = CGPoint(x: 0, y: endRect.origin.y)
                    self.tmpImageView.frame = endRect
                    }, completion: { (success) -> Void in
                        self.view.addSubview(self.collectionView)
                        self.tmpImageView.hidden = true
                })
            }
            else {
                self.view.backgroundColor = UIColor.blackColor()
                self.view.addSubview(self.collectionView)
            }
        }
    }
    
    func dismiss() {
        var currentPictureIndex = 0
        if let cell = self.collectionView.visibleCells()[0] as? MQPictureBrowserCell {
            currentPictureIndex = self.collectionView.indexPathForCell(cell)!.item
        }
        if let imageView = self.dataSource.pictureBrowserController?(self, willHidePictureToImageViewAtIndex: currentPictureIndex) as UIImageView? {
            self.tmpImageView.hidden = false
            self.tmpImageView.image = imageView.image
            self.collectionView.removeFromSuperview()
            let cell = self.collectionView(self.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: currentPictureIndex, inSection: 0)) as! MQPictureBrowserCell
            let imageActualRect = cell.calculateImageActualRect()
            var beginRect = self.view.convertRect(imageActualRect, fromView: cell)
            beginRect.origin = CGPoint(x: 0, y: beginRect.origin.y)
            self.tmpImageView.frame = beginRect
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                let endRect = self.view.convertRect(imageView.frame, fromView: imageView.superview)
                self.tmpImageView.frame = endRect
                }, completion: { (success) -> Void in
                    self.tmpImageView.hidden = true
                    self.dismissViewControllerAnimated(false, completion: nil)
            })
        }
        else {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
}

extension MQPictureBrowserController: MQPictureBrowserCellDelegate {
    
    func pictureBrowserCellTap(pictureBrowserCell: MQPictureBrowserCell) {
        dismiss()
    }
    
}

extension MQPictureBrowserController: UICollectionViewDelegate {
    
}

extension MQPictureBrowserController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInPictureBrowserController(self)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = dataSource.pictureBrowserController(self, cellForItemAtIndex: indexPath.item)
        cell.delegate = self
        return cell
    }
    
}
