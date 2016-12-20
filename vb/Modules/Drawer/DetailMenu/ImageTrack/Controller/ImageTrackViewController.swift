//
//  ImageTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVFoundation
import Kingfisher
import MJRefresh
import AVOSCloud
import MQMaskController
import Photos
import SVProgressHUD
import MKFImageDownloadGroup

class ImageTrackViewController: UIViewController {
    
    var viewModel: ImageTrackViewModel!
    weak var imageTrackBrowserVc: MQPictureBrowserController?
    var addMenuMaskVC: MQMaskController?
    var willShowClosure: ((Void) -> Void)?
    var statusBarHidden: Bool = false
    
    @IBOutlet weak var updateProgressView: UIProgressView!
    @IBOutlet weak var updateProgressLabel: UILabel!
    @IBOutlet weak var updateProgressTop: NSLayoutConstraint!
    
    @IBOutlet weak var imageTrackCollectionView: UICollectionView! {
        didSet {
            configurePullToRefresh()
            
            let group = ImageDownloadGroup(identifier: ImageTrackCell.RealClassName)
            group.maxConcurrentDownloads = 20
            ImageDownloadGroupManage.shareInstance.add(group)
        }
    }
    
    @IBOutlet weak var layout: ImageTrackLayout! {
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
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
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
        viewModel = ImageTrackViewModel()
        layout.cellWidth = (self.view.w - layout.sectionInset.left - layout.sectionInset.right) / CGFloat(layout.numberOfColumns)
        imageTrackCollectionView.mj_header.beginRefreshing()
    }
    
    override var prefersStatusBarHidden : Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .slide
    }
    
    deinit {
        print("\(type(of: self)) deinit\n", terminator: "")
    }
    
}

//  MARK: Private
extension ImageTrackViewController {
    
    //  配置下拉刷新
    func configurePullToRefresh()
    {
        imageTrackCollectionView!.mj_header = MJRefreshNormalHeader() { [unowned self] in
            //  获取成功，就逐条请求存储的imageTrack存在缓存中
            self.viewModel.queryImageTrackListCompletion { [weak self] succeed in
                guard let strongSelf = self else { return }
                guard succeed == true else { strongSelf.imageTrackCollectionView!.mj_header.endRefreshing(); return }
                strongSelf.imageTrackCollectionView.reloadData()
                strongSelf.imageTrackCollectionView!.mj_header.endRefreshing()
            }
        }
    }
    
}

//  MARK: Action
extension ImageTrackViewController {
    
    @IBAction func addImageTrackAction(_ sender: AnyObject!)
    {
        let addMenuView = Bundle.main.loadNibNamed("ImageTrack", owner: nil, options: nil)?[0] as! ImageTrackAddMenuView
        addMenuView.frame = CGRect(x: 0, y: 64, width: addMenuView.w, height: addMenuView.h)
        addMenuView.fromPictureAlbumButton.addTarget(self, action: #selector(ImageTrackViewController.addFromPictureAlbumButtonAction(_:)), for: UIControlEvents.touchUpInside)
        addMenuView.fromCameraButton.addTarget(self, action: #selector(ImageTrackViewController.addFromCameraButtonAction(_:)), for: UIControlEvents.touchUpInside)
        addMenuMaskVC = MQMaskController(maskController: MQMaskControllerType.tipDismiss, withContentView: addMenuView, contentCenter: false, delayTime: 0)
        addMenuMaskVC!.showWith(animated: true, completion: nil)
    }
    
    @objc fileprivate func addFromPictureAlbumButtonAction(_ sender: AnyObject!)
    {
        addMenuMaskVC!.dismissWith(animated: true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerVc.delegate = self
        present(imagePickerVc, animated: true, completion: nil)
    }
    
    @objc fileprivate func addFromCameraButtonAction(_ sender: AnyObject!)
    {
        addMenuMaskVC!.dismissWith(animated: true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.camera
        imagePickerVc.delegate = self
        present(imagePickerVc, animated: true, completion: nil)
    }
    
    @objc fileprivate func saveImage()
    {
        print(imageTrackBrowserVc!.collectionView.indexPathsForVisibleItems)
        let indexPath = imageTrackBrowserVc!.collectionView.indexPathsForVisibleItems[0]
        guard let cell = imageTrackBrowserVc!.collectionView.cellForItem(at: indexPath) as? ImageTrackDisplayCell else { return }
        guard let image = cell.imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ImageTrackViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject)
    {
        guard didFinishSavingWithError == nil else {
            SVProgressHUD.showError(withStatus: "保存失败")
            return
        }
        SVProgressHUD.showSuccess(withStatus: "保存成功")
    }
    
}

//  MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImageTrackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage? else {
            dismiss(animated: true, completion: nil)
            return
        }
        viewModel.queryAddImageTrackWithOringinImage(image, progress: { [weak self] (progress) -> Void in
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
                strongSelf.imageTrackCollectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    strongSelf.updateProgressShow = false
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
}

//  MARK: MQPictureBrowserControllerDataSource MQPictureBrowserControllerDelegate
extension ImageTrackViewController: MQPictureBrowserControllerDataSource, MQPictureBrowserControllerDelegate {
    
    func pictureBrowserController(_ controller: MQPictureBrowserController, animationInfoOfShowPictureAtIndex index: Int) -> ShowAnimationInfo?
    {
        if let cell = imageTrackCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! ImageTrackCell? {
            return (cell.imageView, cell)
        }
        return nil
    }
    
    func pictureBrowserController(_ controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo?
    {
        if let cell = imageTrackCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! ImageTrackCell? {
            return (cell.imageView, cell)
        }
        return nil
    }
    
    func numberOfItemsInPictureBrowserController(_ controller: MQPictureBrowserController) -> Int
    {
        return viewModel.imageTrackModelList.count
    }
    
    func pictureBrowserController(_ controller: MQPictureBrowserController, pictureCellForItemAtIndex index: Int) -> MQPictureBrowserCell
    {
        let imageTrackDisplayCell = controller.collectionView.dequeueReusableCell(withReuseIdentifier: ImageTrackDisplayCell.RealClassName, for: IndexPath(item: index, section: 0)) as! ImageTrackDisplayCell
        imageTrackDisplayCell.configurePictureCell(viewModel.imageTrackModelList[index])
        return imageTrackDisplayCell
    }
    
    func pictureBrowserController(_ controller: MQPictureBrowserController, willDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int)
    {
        guard willShowClosure == nil else { willShowClosure!(); willShowClosure = nil; return }
        imageTrackCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: true)
    }
    
//    func pictureBrowserController(controller: MQPictureBrowserController, didDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int) {
//        
//    }
}

//  MARK: ImageTrackLayoutDelegate
extension ImageTrackViewController: ImageTrackLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth cellWidth: CGFloat) -> CellHeightInfo
    {
        print(indexPath.item)
        if let imageTrack = viewModel.imageTrackModelList[indexPath.item] as ImageTrackModel? {
            let imageWidht = cellWidth - 10 //  转成imageWidth进行计算
            let boundingRect = CGRect(x: 0, y: 0, width: imageWidht, height: CGFloat(MAXFLOAT))
            let imageRect = AVMakeRect(aspectRatio: CGSize(width: imageTrack.imageWidht.doubleValue, height:imageTrack.imageHeight.doubleValue), insideRect: boundingRect)
            let cellHeight = imageRect.height + 10  //  回归cellHeight
            return cellHeight > 300 ? (300, true) : (cellHeight, false)
        }
        return (0, false)
    }

}

//  MARK: UICollectionViewDelegate
extension ImageTrackViewController: UICollectionViewDelegate, ImageTrackCellDelegate {

    func imageTrackCellDidLongPress(_ imageTrackCell: ImageTrackCell, gesture: UIGestureRecognizer)
    {
        let index = imageTrackCollectionView.indexPathForItem(at: gesture.location(in: imageTrackCollectionView))!.item
        let deleteAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.default) { [unowned self] (action) -> Void in
            self.viewModel.queryDeleteImageTrackAtIndex(index) { [weak self] (succeed) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.imageTrackCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: "删除图文迹", preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let vc = MQPictureBrowserController(animationModel: .pictureMoveAndBackgroundFadeOut)
        vc.dataSource = self
        vc.delegate = self
        vc.cellGap = 10
        vc.collectionView.register(UINib(nibName: "ImageTrackDisplayCell", bundle: nil), forCellWithReuseIdentifier: ImageTrackDisplayCell.RealClassName)
        vc.presentFromViewController(self, atIndexPicture: indexPath.item)
        vc.pictureBrowerView.saveButton.addTarget(self, action: #selector(ImageTrackViewController.saveImage), for: .touchUpInside)
        imageTrackBrowserVc = vc
        
        let pictureDownloadGroup = ImageDownloadGroup(identifier: ImageTrackDisplayCell.RealClassName)
        pictureDownloadGroup.maxConcurrentDownloads = 5
        ImageDownloadGroupManage.shareInstance.add(pictureDownloadGroup)
        
        //  这里设置willShowClosure，willShow的delegate时就不用调用了
        willShowClosure = {
            
        }
    }
    
}

//  MARK: UICollectionViewDataSource
extension ImageTrackViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return viewModel.imageTrackModelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTrackCell.RealClassName, for: indexPath) as! ImageTrackCell
        cell.configureCell(viewModel.imageTrackModelList[indexPath.item])
        cell.delegate = self
        return cell
    }
    
}
