//
//  MQPictureBrowserController.swift
//  MQPictureBrowser
//
//  Created by 马权 on 10/7/15.
//  Copyright © 2015 马权. All rights reserved.
//

import UIKit

typealias ShowAnimationInfo = (imageView: UIImageView, fromView: UIView)
typealias HideAnimationInfo = (imageView: UIImageView, toView: UIView)

protocol MQPictureBrowserControllerDataSource: NSObjectProtocol {
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo?
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo?
    func numberOfItemsInPictureBrowserController(controller: MQPictureBrowserController) -> Int
    func pictureBrowserController(controller: MQPictureBrowserController, cellForItemAtIndex index: Int) -> MQPictureBrowserCell
}

public enum MQPictureBorwserAnimationModel {
    case None
    case PictureMove
    case PictureMoveAndBackgroundFadeOut
}


class MQPictureBrowserController: UIViewController {

    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    weak var dataSource: MQPictureBrowserControllerDataSource!
    lazy var tmpImageView = UIImageView()
    var animationModel: MQPictureBorwserAnimationModel = MQPictureBorwserAnimationModel.None
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(animationModel: MQPictureBorwserAnimationModel) {
        self.init()
        self.animationModel = animationModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionViewFlowLayout)
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
        collectionView.hidden = true
        
        view.addSubview(collectionView)
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}

//  MARK: Public
extension MQPictureBrowserController {
    
    func presentFromViewController(viewController: UIViewController!, atIndexPicture index: Int = 0) {
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        viewController.presentViewController(self, animated: false) {
            
            if self.animationModel == MQPictureBorwserAnimationModel.None {
                self.view.backgroundColor = UIColor.blackColor()
                self.view.addSubview(self.collectionView)
            }
            else {
                self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)

                if let showAnimationInfo = self.dataSource.pictureBrowserController(self, animationInfoOfShowPictureAtIndex: index) as ShowAnimationInfo? {
                    
                    if self.animationModel == MQPictureBorwserAnimationModel.PictureMove {
                        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)        //  初始化背景为黑色
                        self.view.addSubview(self.tmpImageView)                                         //  先将动画图片加在self.view上
                        self.tmpImageView.image = showAnimationInfo.imageView.image                     //  设置动画图片内容
                        let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                        self.tmpImageView.frame = beginRect                                             //  设置动画其实坐标
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            let caculateEndRect: (cell: MQPictureBrowserCell) -> CGRect = { cell in
                                let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                                return self.view.convertRect(imageActualRect, fromView: cell)
                            }
                            let cell = self.dataSource.pictureBrowserController(self, cellForItemAtIndex: index)
                            var endRect = CGRectZero
                            if cell.superview == nil {
                                self.collectionView.addSubview(cell)
                                endRect = caculateEndRect(cell: cell)
                                cell.removeFromSuperview()
                            }
                            else {
                                endRect = caculateEndRect(cell: cell)
                            }
                            self.tmpImageView.frame = endRect
                            }, completion: { (success) -> Void in
                                self.collectionView.hidden = false
                                self.tmpImageView.removeFromSuperview()
                        })
                    }
                    
                    if self.animationModel == MQPictureBorwserAnimationModel.PictureMoveAndBackgroundFadeOut {
                        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)            //  初始化背景为白色
                        self.view.addSubview(self.tmpImageView)                                             //  先将动画图片加在self.view上
                        self.tmpImageView.image = showAnimationInfo.imageView.image                         //  设置动画图片内容
                        let beginRect = self.view.convertRect(showAnimationInfo.imageView.frame, fromView: showAnimationInfo.imageView.superview)
                        self.tmpImageView.frame = beginRect                                                 //  设置动画其实坐标
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)        //  初始化背景为黑色
                            let caculateEndRect: (cell: MQPictureBrowserCell) -> CGRect = { cell in
                                let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                                return self.view.convertRect(imageActualRect, fromView: cell)
                            }
                            let cell = self.dataSource.pictureBrowserController(self, cellForItemAtIndex: index)
                            var endRect = CGRectZero
                            if cell.superview == nil {
                                self.collectionView.addSubview(cell)
                                endRect = caculateEndRect(cell: cell)
                                cell.removeFromSuperview()
                            }
                            else {
                                endRect = caculateEndRect(cell: cell)
                            }
                            self.tmpImageView.frame = endRect
                            }, completion: { (success) -> Void in
                                self.collectionView.hidden = false
                                self.tmpImageView.removeFromSuperview()
                        })
                    }

                }
                else {
                    self.view.backgroundColor = UIColor.blackColor()
                    self.view.addSubview(self.collectionView)
                }
            }
        }
    }
    
    func dismiss() {
        var currentPictureIndex = 0
        if let cell = self.collectionView.visibleCells()[0] as? MQPictureBrowserCell {
            currentPictureIndex = self.collectionView.indexPathForCell(cell)!.item
        }
        
        if animationModel == MQPictureBorwserAnimationModel.None {
            dismissViewControllerAnimated(false, completion: nil)
        }
        else {
            if let hideAnimationInfo = self.dataSource.pictureBrowserController(self, animationInfoOfHidePictureAtIndex: currentPictureIndex) as HideAnimationInfo? {
                
                if animationModel == MQPictureBorwserAnimationModel.PictureMove {
                    hideAnimationInfo.toView.addSubview(self.tmpImageView)                          //  先将临时动画视图加载toView上
                    self.tmpImageView.image = hideAnimationInfo.imageView.image                     //  设置动画图片内容

                    let caculateEndRect: (cell: MQPictureBrowserCell) -> CGRect = { cell in
                        let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                        return hideAnimationInfo.toView.convertRect(imageActualRect, fromView: cell)
                    }
                    let cell = self.dataSource.pictureBrowserController(self, cellForItemAtIndex: currentPictureIndex)
                    var beginRect = CGRectZero
                    if cell.superview == nil {
                        self.collectionView.addSubview(cell)
                        beginRect = caculateEndRect(cell: cell)
                        cell.removeFromSuperview()
                    }
                    else {
                        beginRect = caculateEndRect(cell: cell)
                    }
                    self.tmpImageView.frame = beginRect
            
                    dismissViewControllerAnimated(false) {
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            let endRect = hideAnimationInfo.toView.convertRect(hideAnimationInfo.imageView.frame, fromView: hideAnimationInfo.imageView.superview)
                            self.tmpImageView.frame = endRect                                           //  设置最终位置
                            }, completion: { (success) -> Void in
                                self.tmpImageView.removeFromSuperview()
                        })
                    }
                }
                
                if animationModel == MQPictureBorwserAnimationModel.PictureMoveAndBackgroundFadeOut {
                    self.view.addSubview(self.tmpImageView)
                    self.tmpImageView.image = hideAnimationInfo.imageView.image
                    self.collectionView.hidden = true
                    
                    let caculateEndRect: (cell: MQPictureBrowserCell) -> CGRect = { cell in
                        let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                        return self.view.convertRect(imageActualRect, fromView: cell)
                    }
                    
                    let cell = self.dataSource.pictureBrowserController(self, cellForItemAtIndex: currentPictureIndex)
                    var beginRect = CGRectZero
                    if cell.superview == nil {
                        self.collectionView.addSubview(cell)
                        beginRect = caculateEndRect(cell: cell)
                        cell.removeFromSuperview()
                    }
                    else {
                        beginRect = caculateEndRect(cell: cell)
                    }
                    self.tmpImageView.frame = beginRect
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                        let endRect = self.view.convertRect(hideAnimationInfo.imageView.frame, fromView: hideAnimationInfo.imageView.superview)
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                    })
                }

            }
            else {
                dismissViewControllerAnimated(false, completion: nil)
            }
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
