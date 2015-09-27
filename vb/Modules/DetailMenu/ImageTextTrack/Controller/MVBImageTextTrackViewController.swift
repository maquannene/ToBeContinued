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
        collectionView!.header = MJRefreshNormalHeader() {
            //  首先试图获取存有每条imageTextTrack 的 id 列表
            self.dataSource.queryFindImageTextTrackIdList {
                guard $0 == true else {
                    //  如果获取失败，就创建新的
                    self.dataSource.queryCreateImageTextTrackIdList { [unowned self] succeed in
                        self.collectionView!.header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的imageTextTrack存在缓存中
                self.dataSource.queryImageTextTrackList { [unowned self] succeed in
                    guard succeed == true else { self.collectionView!.header.endRefreshing(); return }
                    self.collectionView.reloadData()
                    self.collectionView!.header.endRefreshing()
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
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        let imageFile = AVFile(name: "maquan", data: imageData)
        
        let newImage = UIImage(data: imageData!)
        print(NSData.sd_contentTypeForImageData(imageData))
        
        let newImageData = UIImageJPEGRepresentation(newImage!, 1)
        print(NSData.sd_contentTypeForImageData(newImageData))
        
        imageFile.saveInBackgroundWithBlock ( { [unowned self] succeed, error in
            //  这一步非常重要，将已经保存在云上的图片再存入disk cache一份，这样就不用每次都要从云端下载图片了
//            imageFile.getThumbnail(true, width: (Int32)(image.size.width), height: (Int32)(image.size.height)) { image, error in
//                SDWebImageManager.sharedManager().saveImageToCache(image, forURL: NSURL(string: imageFile.url))
//            }
            print("image Url: \(imageFile.url) \n size: \(image.size) \n text: xxx \n image length: \(imageData!.length)")
            self.dataSource.queryAddImageTextTrack(MVBImageTextTrackModel(imageUrl: imageFile.url, text: "xxx", imageSize: image.size), complete: { (succeed) -> Void in
                self.collectionView.reloadData()
            })
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

//  MARK: UICollectionViewDelegate
extension MVBImageTextTrackViewController: UICollectionViewDelegate {
    
}

//  MARK: UICollectionViewDataSource
extension MVBImageTextTrackViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.imageTextTrackList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MVBImageTextTrackCell.ClassName, forIndexPath: indexPath) as! MVBImageTextTrackCell
        cell.imageTextTrack = dataSource.imageTextTrackList[indexPath.item] as? MVBImageTextTrackModel
        return cell
    }
    
}
