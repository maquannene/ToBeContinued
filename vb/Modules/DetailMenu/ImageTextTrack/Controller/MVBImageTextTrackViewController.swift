//
//  MVBImageTextTrackViewController.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import AVFoundation

class MVBImageTextTrackViewController: UIViewController {
    
    var imageUrl: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: MVBImageTextTrackLayout!
    var dataSource: MVBImageTextTrackDataSource!
    
    //  模拟数据源数组
//    lazy var imageTextTracks: [MVBImageTextTrackModel] = MVBImageTextTrackModel.allImageTextTrack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.redColor()
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addImageTextTrackAction:")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "getImage:")
        
        layout.delegate = self
        layout.numberOfColumns = 2
        dataSource = MVBImageTextTrackDataSource()
        
        configurePullToRefresh()
        collectionView.header.beginRefreshing()
    }
    
}

//  MARK: Private
extension MVBImageTextTrackViewController {
    
    //  配置下拉刷新
    func configurePullToRefresh() {
        collectionView!.header = MJRefreshNormalHeader() { [unowned self] in
            //  首先试图获取存有每条imageTextTrack 的 id 列表
            self.dataSource.queryFindImageTextTrackIdList { [weak self] in
                guard let strongSelf = self else { return }
                guard $0 == true else {
                    //  如果获取失败，就创建新的
                    strongSelf.dataSource.queryCreateImageTextTrackIdList { [weak self] succeed in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView!.header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的imageTextTrack存在缓存中
                strongSelf.dataSource.queryImageTextTrackList { [weak self] succeed in
                    guard let strongSelf = self else { return }
                    guard succeed == true else { strongSelf.collectionView!.header.endRefreshing(); return }
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView!.header.endRefreshing()
                }
            }
        }
    }
    
}

//  MARK: Action
extension MVBImageTextTrackViewController {
    
    func addImageTextTrackAction(sender: AnyObject!) {
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerVc.delegate = self
        presentViewController(imagePickerVc, animated: true, completion: nil)
    }
    
    func getImage(sender: AnyObject!) {
        let fileImage = AVFile(URL: imageUrl)
        fileImage.getThumbnail(true, width: 100, height: 100) { image, error in
            let imageView = UIImageView(image: image)
            print(image)
        }
    }
    
}

extension MVBImageTextTrackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage? else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }

        //  压缩图像
        let imageData = UIImageJPEGRepresentation(image, 0.000001)
        let imageFile = AVFile(name: "maquan", data: imageData)
        
        //  存储图片到云端
        imageFile.saveInBackgroundWithBlock( { [unowned self] succeed, error in
            print("image Url: \(imageFile.url) \n size: \(image.size) \n text: xxx \n image length: \(imageData!.length) size: \(imageFile.size)")
            //  存完了就删除硬盘缓存，因为暂时没有理由需要硬盘缓存
            imageFile.clearCachedFile()
            //  这一步非常重要，将已经保存在云上的图片再存入disk cache一份，cell加载时就不用再用网络下载了
            let newImage = UIImage(data: imageData!)    //  这里用data 还原的 image 大小还是有问题
            SDWebImageManager.sharedManager().saveImageToCache(newImage, forURL: NSURL(string: imageFile.url))
            //  将新生成的textTrackModel再存到云端
            let textTrackModel: MVBImageTextTrackModel = MVBImageTextTrackModel(imageUrl: imageFile.url, text: "编号：\(self.dataSource.imageTextTrackList.count + 1)", imageSize: image.size)
            self.dataSource.queryAddImageTextTrack(textTrackModel) { [weak self] success in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
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

extension MVBImageTextTrackViewController: JTSImageViewControllerAccessibilityDelegate {
    func accessibilityLabelForImageViewer(imageViewer: JTSImageViewController!) -> String! {
        return imageViewer.imageInfo.title
    }
}

//  MARK: UICollectionViewDelegate
extension MVBImageTextTrackViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MVBImageTextTrackCell else { return }
        let imageInfo = JTSImageInfo()
        imageInfo.image = cell.imageView.image
        imageInfo.title = cell.imageTextTrack.text
        imageInfo.referenceRect = cell.imageView.frame
        imageInfo.referenceView = cell
        let imageViewerController = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        imageViewerController.accessibilityDelegate = self
        imageViewerController.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
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
        return cell
    }
    
}
