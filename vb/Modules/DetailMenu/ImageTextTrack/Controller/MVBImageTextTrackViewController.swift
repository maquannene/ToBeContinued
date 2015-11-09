//
//  MVBImageTextTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVFoundation
import SDWebImage
import MJRefresh
import AVOSCloud
import MQMaskController
import Photos
import SVProgressHUD

class MVBImageTextTrackViewController: UIViewController {
    
    var dataSource: MVBImageTextTrackViewModel!
    weak var imageTextTrackBrowserVc: MQPictureBrowserController?
    var addMenuMaskVC: MQMaskController?
    var willShowClosure: (Void -> Void)?
    var statusBarHidden: Bool = false
    
    @IBOutlet weak var updateProgressView: UIProgressView!
    @IBOutlet weak var updateProgressLabel: UILabel!
    @IBOutlet weak var updateProgressTop: NSLayoutConstraint!
    
    @IBOutlet weak var imageTextTrackCollectionView: UICollectionView! {
        didSet {
            configurePullToRefresh()
        }
    }
    
    @IBOutlet weak var layout: MVBImageTextTrackLayout! {
        didSet {
            layout.delegate = self
            layout.numberOfColumns = 2
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var updateProgressShow: Bool {
        set {
            statusBarHidden = newValue
            if newValue == true {
                updateProgressTop.constant = 0
            }
            else {
                updateProgressTop.constant = -20
            }
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.5, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        get {
            return updateProgressTop.constant == 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MVBImageTextTrackViewModel()
        layout.cellWidth = (self.view.w - layout.sectionInset.left - layout.sectionInset.right) / CGFloat(layout.numberOfColumns)
        imageTextTrackCollectionView.mj_header.beginRefreshing()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}

//  MARK: Private
extension MVBImageTextTrackViewController {
    
    //  配置下拉刷新
    func configurePullToRefresh() {
        imageTextTrackCollectionView!.mj_header = MJRefreshNormalHeader() { [unowned self] in
            //  首先试图获取存有每条imageTextTrack 的 id 列表
            self.dataSource.queryFindImageTextTrackIdList { [weak self] in
                guard let strongSelf = self else { return }
                guard $0 == true else {
                    //  如果获取失败，就创建新的
                    strongSelf.dataSource.queryCreateImageTextTrackIdList { [weak self] succeed in
                        guard let strongSelf = self else { return }
                        strongSelf.imageTextTrackCollectionView!.mj_header.endRefreshing()
                    }
                    return
                }
                //  获取成功，就逐条请求存储的imageTextTrack存在缓存中
                strongSelf.dataSource.queryImageTextTrackList { [weak self] succeed in
                    guard let strongSelf = self else { return }
                    guard succeed == true else { strongSelf.imageTextTrackCollectionView!.mj_header.endRefreshing(); return }
                    strongSelf.imageTextTrackCollectionView.reloadData()
                    strongSelf.imageTextTrackCollectionView!.mj_header.endRefreshing()
                }
            }
        }
    }
    
}

//  MARK: Action
extension MVBImageTextTrackViewController {
    
    @IBAction func addImageTextTrackAction(sender: AnyObject!) {
        let addMenuView = NSBundle.mainBundle().loadNibNamed("MVBImageTextTrack", owner: nil, options: nil)[0] as! MVBImageTextTrackAddMenuView
        addMenuView.frame = CGRect(x: 0, y: 64, width: addMenuView.w, height: addMenuView.h)
        addMenuView.fromPictureAlbumButton.addTarget(self, action: "addFromPictureAlbumButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        addMenuView.fromCameraButton.addTarget(self, action: "addFromCameraButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        addMenuMaskVC = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: addMenuView, contentCenter: false, delayTime: 0)
        addMenuMaskVC!.showWithAnimated(true, completion: nil)
    }
    
    @objc private func addFromPictureAlbumButtonAction(sender: AnyObject!) {
        addMenuMaskVC!.dismissWithAnimated(true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerVc.delegate = self
        presentViewController(imagePickerVc, animated: true, completion: nil)
    }
    
    @objc private func addFromCameraButtonAction(sender: AnyObject!) {
        addMenuMaskVC!.dismissWithAnimated(true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerVc.delegate = self
        presentViewController(imagePickerVc, animated: true, completion: nil)
    }
    
    @objc private func saveImage() {
        print(imageTextTrackBrowserVc!.collectionView.indexPathsForVisibleItems())
        let indexPath = imageTextTrackBrowserVc!.collectionView.indexPathsForVisibleItems()[0]
        guard let cell = imageTextTrackBrowserVc!.collectionView.cellForItemAtIndexPath(indexPath) as? MVBImageTextTrackDisplayCell else { return }
        guard let image = cell.imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        guard didFinishSavingWithError == nil else {
            SVProgressHUD.showErrorWithStatus("保存失败")
            return
        }
        SVProgressHUD.showSuccessWithStatus("保存成功")
    }
    
}

//  MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MVBImageTextTrackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage? else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        dataSource.queryAddImageTextTrack(image, progressClosure: { [weak self] (progress) -> Void in
            print("大图上传进度: \(progress)")
            guard let strongSelf = self else { return }
            strongSelf.updateProgressShow = true
            strongSelf.updateProgressView.progress = Float(progress) / Float(100) * 0.9
            strongSelf.updateProgressLabel.text = "上传进度:\(Float(progress) * 0.9)%"
            }) { [weak self] (succeed) -> Void in
                guard let strongSelf = self else { return }
                guard succeed == true else { strongSelf.updateProgressShow = false; return }
                strongSelf.updateProgressView.progress = 1
                strongSelf.updateProgressLabel.text = "长传成功"
                strongSelf.imageTextTrackCollectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    strongSelf.updateProgressShow = false
                })
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

//  MARK: MQPictureBrowserControllerDataSource MQPictureBrowserControllerDelegate
extension MVBImageTextTrackViewController: MQPictureBrowserControllerDataSource, MQPictureBrowserControllerDelegate {
    
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo? {
        if let cell = imageTextTrackCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as! MVBImageTextTrackCell? {
            return (cell.imageView, cell)
        }
        return nil
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo? {
        if let cell = imageTextTrackCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as! MVBImageTextTrackCell? {
            return (cell.imageView, cell)
        }
        return nil
    }
    
    func numberOfItemsInPictureBrowserController(controller: MQPictureBrowserController) -> Int {
        return dataSource.imageTextTrackList.count
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, pictureCellForItemAtIndex index: Int) -> MQPictureBrowserCell {
        let imageTextTrackDisplayCell = controller.collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackDisplayCell.ClassName, forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! MVBImageTextTrackDisplayCell
        imageTextTrackDisplayCell.configurePictureCell(dataSource.imageTextTrackList[index] as! MVBImageTextTrackModel)
        return imageTextTrackDisplayCell
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, willDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int) {
        guard willShowClosure == nil else { willShowClosure!(); willShowClosure = nil; return }
        imageTextTrackCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredVertically, animated: true)
    }
    
//    func pictureBrowserController(controller: MQPictureBrowserController, didDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int) {
//        
//    }
}

//  MARK: MVBImageTextTrackLayoutDelegate
extension MVBImageTextTrackViewController: MVBImageTextTrackLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth cellWidth: CGFloat) -> CellHeightInfo {
        print(indexPath.item)
        let imageTextTrack = dataSource.imageTextTrackList[indexPath.item] as! MVBImageTextTrackModel
        let imageWidht = cellWidth - 10 //  转成imageWidth进行计算
        let boundingRect = CGRect(x: 0, y: 0, width: imageWidht, height: CGFloat(MAXFLOAT))
        let imageRect = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageTextTrack.imageWidht.doubleValue, height:imageTextTrack.imageHeight.doubleValue), boundingRect)
        let cellHeight = imageRect.height + 10  //  回归cellHeight
        return cellHeight > 300 ? (300, true) : (cellHeight, false)
    }

}

//  MARK: UICollectionViewDelegate
extension MVBImageTextTrackViewController: UICollectionViewDelegate, MVBImageTextTrackCellDelegate {

    func imageTextTrackCellDidLongPress(imageTextTrackCell: MVBImageTextTrackCell, gesture: UIGestureRecognizer) {
        let index = imageTextTrackCollectionView.indexPathForItemAtPoint(gesture.locationInView(imageTextTrackCollectionView))!.item
        let deleteAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Default) { [unowned self] (action) -> Void in
            self.dataSource.queryDeleteImageTextTrack(index, complete: { [weak self] (succeed) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.imageTextTrackCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            })
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: "删除图文迹", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = MQPictureBrowserController(animationModel: .PictureMoveAndBackgroundFadeOut)
        vc.dataSource = self
        vc.delegate = self
        vc.cellGap = 10
        vc.collectionView.registerNib(UINib(nibName: "MVBImageTextTrackDisplayCell", bundle: nil), forCellWithReuseIdentifier: MVBImageTextTrackDisplayCell.ClassName)
        vc.presentFromViewController(self, atIndexPicture: indexPath.item)
        vc.pictureBrowerView.saveButton.addTarget(self, action: "saveImage", forControlEvents: .TouchUpInside)
        imageTextTrackBrowserVc = vc
        //  这里设置willShowClosure，willShow的delegate时就不用调用了
        willShowClosure = {
            
        }
    }
    
}

//  MARK: UICollectionViewDataSource
extension MVBImageTextTrackViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.imageTextTrackList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackCell.ClassName, forIndexPath: indexPath) as! MVBImageTextTrackCell
        cell.configureCell(dataSource.imageTextTrackList[indexPath.item] as! MVBImageTextTrackModel)
        cell.delegate = self
        return cell
    }
    
}
