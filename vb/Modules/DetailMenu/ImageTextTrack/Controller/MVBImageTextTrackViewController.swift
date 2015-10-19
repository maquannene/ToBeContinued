//
//  MVBImageTextTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVFoundation

class MVBImageTextTrackViewController: UIViewController {
    
    @IBOutlet weak var imageTextTrackCollectionView: UICollectionView!
    @IBOutlet weak var layout: MVBImageTextTrackLayout!
    var dataSource: MVBImageTextTrackDataSource!
    weak var imageTextTrackBrowserVc: MQPictureBrowserController?
    var addMenuMaskVC: MQMaskController?
    
    var progressDic: [String:CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addImageTextTrackAction:")
        
        layout.delegate = self
        layout.numberOfColumns = 2
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.cellWidth = (self.view.w - layout.sectionInset.left - layout.sectionInset.right) / CGFloat(layout.numberOfColumns)
        
        dataSource = MVBImageTextTrackDataSource()
        
        configurePullToRefresh()
        imageTextTrackCollectionView.header.beginRefreshing()
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
    
}

//  MARK: Private
extension MVBImageTextTrackViewController {
    
    //  配置下拉刷新
    func configurePullToRefresh() {
        imageTextTrackCollectionView!.header = MJRefreshNormalHeader() { [unowned self] in
            //  首先试图获取存有每条imageTextTrack 的 id 列表
            self.dataSource.queryFindImageTextTrackIdList { [weak self] in
                guard let strongSelf = self else { return }
                guard $0 == true else {
                    //  如果获取失败，就创建新的
                    strongSelf.dataSource.queryCreateImageTextTrackIdList { [weak self] succeed in
                        guard let strongSelf = self else { return }
                        strongSelf.imageTextTrackCollectionView!.header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的imageTextTrack存在缓存中
                strongSelf.dataSource.queryImageTextTrackList { [weak self] succeed in
                    guard let strongSelf = self else { return }
                    guard succeed == true else { strongSelf.imageTextTrackCollectionView!.header.endRefreshing(); return }
                    strongSelf.imageTextTrackCollectionView.reloadData()
                    strongSelf.imageTextTrackCollectionView!.header.endRefreshing()
                }
            }
        }
    }
    
}

//  MARK: Action
extension MVBImageTextTrackViewController {
    
    func addImageTextTrackAction(sender: AnyObject!) {
        let addMenuView = NSBundle.mainBundle().loadNibNamed("MVBImageTextTrack", owner: nil, options: nil)[0] as! MVBImageTextTrackAddMenuView
        addMenuView.frame = CGRect(x: 0, y: 64, width: addMenuView.w, height: addMenuView.h)
        addMenuView.fromPictureAlbumButton.addTarget(self, action: "addFromPictureAlbumButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        addMenuView.fromCameraButton.addTarget(self, action: "addFromCameraButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        addMenuMaskVC = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: addMenuView, contentCenter: false, delayTime: 0)
        addMenuMaskVC!.showWithAnimated(true, completion: nil)
    }
    
    func addFromPictureAlbumButtonAction(sender: AnyObject!) {
        addMenuMaskVC!.dismissWithAnimated(true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerVc.delegate = self
        presentViewController(imagePickerVc, animated: true, completion: nil)
    }
    
    func addFromCameraButtonAction(sender: AnyObject!) {
        addMenuMaskVC!.dismissWithAnimated(true, completion: nil)
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerVc.delegate = self
        presentViewController(imagePickerVc, animated: true, completion: nil)
    }
    
}

//  MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MVBImageTextTrackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage? else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }

        let imageData = UIImageJPEGRepresentation(image, 0)
        let imageFile = AVFile(name: "maquan", data: imageData)
        
        //  存储图片到云端
        imageFile.saveInBackgroundWithBlock( { [unowned self, weak imageFile] succeed, error in
            guard let weakImageFile = imageFile else { return }
            print("image Url: \(weakImageFile.url) \n size: \(image.size) \n text: xxx \n image length: \(imageData!.length) size: \(weakImageFile.size() / 1024) KB")
            //  很重要,将imageData存到SDImageCache的disk cache中
            NSFileManager.defaultManager().createFileAtPath(SDImageCache.sharedImageCache().defaultCachePathForKey(weakImageFile.url), contents: imageData, attributes: nil)
            //  将本地的AVCacheFile缓存清理掉
            weakImageFile.clearCachedFile()
            //  将新生成的textTrackModel再存到云端
            let textTrackModel: MVBImageTextTrackModel = MVBImageTextTrackModel(imageFileUrl: weakImageFile.url, imageFileObjectId: weakImageFile.objectId, text: nil, imageSize: image.size)
            self.dataSource.queryAddImageTextTrack(textTrackModel) { [weak self] success in
                guard let strongSelf = self else { return }
                strongSelf.imageTextTrackCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            }
        }) { process in
            print("上传照片进度： \(process)")
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
            return (cell.imageView, imageTextTrackCollectionView)
        }
        return nil
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, animationInfoOfHidePictureAtIndex index: Int) -> HideAnimationInfo? {
        if let cell = imageTextTrackCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as! MVBImageTextTrackCell? {
            return (cell.imageView, imageTextTrackCollectionView)
        }
        return nil
    }
    
    func numberOfItemsInPictureBrowserController(controller: MQPictureBrowserController) -> Int {
        return dataSource.imageTextTrackList.count
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, pictureCellForItemAtIndex index: Int) -> MQPictureBrowserCell {
        let picturebrowserCell = controller.collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackDisplayCell.ClassName, forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! MVBImageTextTrackDisplayCell
        picturebrowserCell.configurePictureCell(dataSource.imageTextTrackList[index] as! MVBImageTextTrackModel)
        return picturebrowserCell
    }
    
    func pictureBrowserController(controller: MQPictureBrowserController, willDisplayCell pictureCell: MQPictureBrowserCell, forItemAtIndex index: Int) {
        imageTextTrackCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
}

//  MARK: MVBImageTextTrackLayoutDelegate
extension MVBImageTextTrackViewController: MVBImageTextTrackLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        print(indexPath.item)
        let imageTextTrack = dataSource.imageTextTrackList[indexPath.item] as! MVBImageTextTrackModel
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRectWithAspectRatioInsideRect(CGSize(width: imageTextTrack.imageWidht.doubleValue, height:imageTextTrack.imageHeight.doubleValue), boundingRect)
        return rect.height
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
        vc.collectionView.registerClass(MVBImageTextTrackDisplayCell.self, forCellWithReuseIdentifier: MVBImageTextTrackDisplayCell.ClassName)
        vc.presentFromViewController(self, atIndexPicture: indexPath.item)
        imageTextTrackBrowserVc = vc
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
