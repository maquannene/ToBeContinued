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

@objc protocol MQPictureBrowserControllerDelegate: NSObjectProtocol {
    @objc optional func pictureBrowserController(_ controller: MQPictureBrowserController, willDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int)
//    optional func pictureBrowserController(controller: MQPictureBrowserController, didDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int)
}

protocol MQPictureBrowserControllerDataSource: NSObjectProtocol {
    func pictureBrowserController(_ controller: MQPictureBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo?
    func pictureBrowserController(_ controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo?
    func numberOfItemsInPictureBrowserController(_ controller: MQPictureBrowserController) -> Int
    func pictureBrowserController(_ controller: MQPictureBrowserController, pictureCellForItemAtIndex index: Int) -> MQPictureBrowserCell
}

public enum MQPictureBorwserAnimationModel {
    case pictureMove
    case pictureMoveAndBackgroundFadeOut                //  default
}


class MQPictureBrowserController: UIViewController {

    var collectionView: UICollectionView!
    weak var dataSource: MQPictureBrowserControllerDataSource?
    weak var delegate: MQPictureBrowserControllerDelegate?
    var animationModel: MQPictureBorwserAnimationModel = .pictureMoveAndBackgroundFadeOut
    var cellGap: CGFloat = 0
    var currentIndex: Int = 0
    
    var pictureBrowerView: MQPictureBrowserView {
        return self.view as! MQPictureBrowserView
    }
    
    fileprivate var collectionViewFlowLayout: UICollectionViewFlowLayout!
    fileprivate lazy var tmpImageView = UIImageView()
    fileprivate lazy var blurEffect = UIBlurEffect(style: .extraLight)
    fileprivate var blurEffectView: UIVisualEffectView!
    fileprivate var statusBarHidden: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewFlowLayout)
        animationModel = .pictureMoveAndBackgroundFadeOut
        
        blurEffectView = UIVisualEffectView(effect: blurEffect) //  毛玻璃效果
    }
    
    convenience init(animationModel: MQPictureBorwserAnimationModel) {
        self.init()
        self.animationModel = animationModel
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("MQPictureBrowserView", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 0, width: UIWindow.windowSize().width, height: UIWindow.windowSize().height)
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        self.view.backgroundColor = RGBA(255, 255, 255, 0)
        
        collectionViewFlowLayout.minimumLineSpacing = cellGap
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: cellGap / 2, left: cellGap / 2, bottom: cellGap / 2, right: cellGap / 2)
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.w - cellGap, height: self.view.h - cellGap)
        
        collectionView.frame = self.view.bounds
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        view.addSubview(collectionView)
        view.insertSubview(collectionView, aboveSubview: blurEffectView)
        
        tmpImageView.clipsToBounds = true
        tmpImageView.layer.cornerRadius = 7.5
        tmpImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        blurEffectView.alpha = 0
        blurEffectView.frame = self.view.bounds
        
        pictureBrowerView.saveButton.isHidden = true
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    deinit {
        print("\(type(of: self)) deinit\n", terminator: "")
    }
    
}

//  MARK: Public
extension MQPictureBrowserController {
    
    func presentFromViewController(_ viewController: UIViewController!, atIndexPicture index: Int = 0) {
    
        self.statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        viewController.present(self, animated: false) {
            
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)

            if let showAnimationInfo = self.dataSource!.pictureBrowserController(self, animationInfoOfShowPictureAtIndex: index) as ShowAnimationInfo? {
                
                if self.animationModel == .pictureMove {
                    self.blurEffectView.alpha = 0
                    self.view.backgroundColor = RGBA(0, 0, 0, 1)
                    self.view.addSubview(self.tmpImageView)                                         //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                     //  设置动画图片内容
                    let beginRect = self.view.convert(showAnimationInfo.imageView.frame, from: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                             //  设置动画其实坐标
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        let caculateEndRect: (_ cell: MQPictureBrowserCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convert(imageActualRect, from: cell)
                        }
                        let cell = self.dataSource!.pictureBrowserController(self, pictureCellForItemAtIndex: index)
                        var endRect = CGRect.zero
                        if cell.superview == nil {
                            self.collectionView.addSubview(cell)
                            endRect = caculateEndRect(cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.collectionView.isHidden = false
                            self.pictureBrowerView.saveButton.isHidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
                
                if self.animationModel == .pictureMoveAndBackgroundFadeOut {
                    self.view.addSubview(self.tmpImageView)                                             //  先将动画图片加在self.view上
                    self.tmpImageView.image = showAnimationInfo.imageView.image                         //  设置动画图片内容
                    let beginRect = self.view.convert(showAnimationInfo.imageView.frame, from: showAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = beginRect                                                 //  设置动画其实坐标
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.blurEffectView.alpha = 0.9
                        let caculateEndRect: (_ cell: MQPictureBrowserCell) -> CGRect = { cell in
                            let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                            return self.view.convert(imageActualRect, from: cell)
                        }
                        let cell = self.dataSource!.pictureBrowserController(self, pictureCellForItemAtIndex: index)
                        var endRect = CGRect.zero
                        if cell.superview == nil {
                            self.collectionView.addSubview(cell)
                            endRect = caculateEndRect(cell)
                            cell.removeFromSuperview()
                        }
                        else {
                            endRect = caculateEndRect(cell)
                        }
                        self.tmpImageView.frame = endRect
                        }, completion: { (success) -> Void in
                            self.collectionView.isHidden = false
                            self.pictureBrowerView.saveButton.isHidden = false
                            self.tmpImageView.removeFromSuperview()
                    })
                }
            }
            else {
                self.view.backgroundColor = RGBA(0, 0, 0, 0.3)
                self.view.addSubview(self.collectionView)
            }
        }
    }
    
    func dismiss() {
        
        var currentPictureIndex = 0
        if let cell = self.collectionView.visibleCells[0] as? MQPictureBrowserCell {
            currentPictureIndex = self.collectionView.indexPath(for: cell)!.item
        }
        
        if let hideAnimationInfo = self.dataSource!.pictureBrowserController(self, animationInfoOfHidePictureAtIndex: currentPictureIndex) as HideAnimationInfo? {
            
            if animationModel == .pictureMove {
                hideAnimationInfo.toView.addSubview(self.tmpImageView)                          //  先将临时动画视图加载toView上
                self.tmpImageView.image = hideAnimationInfo.imageView.image                     //  设置动画图片内容

                let caculateEndRect: (_ cell: MQPictureBrowserCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return hideAnimationInfo.toView.convert(imageActualRect, from: cell)
                }
                let cell = self.dataSource!.pictureBrowserController(self, pictureCellForItemAtIndex: currentPictureIndex)
                var beginRect = CGRect.zero
                if cell.superview == nil {
                    self.collectionView.addSubview(cell)
                    beginRect = caculateEndRect(cell)
                    cell.removeFromSuperview()
                }
                else {
                    beginRect = caculateEndRect(cell)
                }
                self.tmpImageView.frame = beginRect
        
                self.dismiss(animated: false) {
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        let endRect = hideAnimationInfo.toView.convert(hideAnimationInfo.imageView.frame, from: hideAnimationInfo.imageView.superview)
                        self.tmpImageView.frame = endRect                                           //  设置最终位置
                        }, completion: { (success) -> Void in
                            self.tmpImageView.removeFromSuperview()
                    })
                }
            }
            
            if animationModel == .pictureMoveAndBackgroundFadeOut {
                self.view.addSubview(self.tmpImageView)
                self.tmpImageView.image = hideAnimationInfo.imageView.image
                self.collectionView.isHidden = true
                self.pictureBrowerView.saveButton.isHidden = true
                
                let caculateEndRect: (_ cell: MQPictureBrowserCell) -> CGRect = { cell in
                    let imageActualRect = cell.calculateImageActualRectInCell(cell.imageSize)
                    return self.view.convert(imageActualRect, from: cell)
                }
                
                let cell = self.dataSource!.pictureBrowserController(self, pictureCellForItemAtIndex: currentPictureIndex)
                var beginRect = CGRect.zero
                if cell.superview == nil {
                    self.collectionView.addSubview(cell)
                    beginRect = caculateEndRect(cell)
                    cell.removeFromSuperview()
                }
                else {
                    beginRect = caculateEndRect(cell)
                }
                self.tmpImageView.frame = beginRect
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.blurEffectView.alpha = 0
                    let endRect = self.view.convert(hideAnimationInfo.imageView.frame, from: hideAnimationInfo.imageView.superview)
                    self.tmpImageView.frame = endRect
                    }, completion: { (success) -> Void in
                        self.dismiss(animated: false, completion: nil)
                })
            }

        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}

extension MQPictureBrowserController: MQPictureBrowserCellDelegate {
    
    func pictureBrowserCellTap(_ pictureBrowserCell: MQPictureBrowserCell) {
        dismiss()
    }
    
}

extension MQPictureBrowserController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageTextCell = cell as? MQPictureBrowserCell else { return }
        currentIndex = indexPath.item
        delegate?.pictureBrowserController?(self, willDisplayCell: imageTextCell, forItemAtIndex: indexPath.item)
    }
    
}

extension MQPictureBrowserController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItemsInPictureBrowserController(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dataSource!.pictureBrowserController(self, pictureCellForItemAtIndex: indexPath.item)
        cell.delegate = self
        return cell
    }
    
}
