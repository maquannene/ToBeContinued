//
//  ImageTrackViewModel.swift
//  vb
//
//  Created by 马权 on 9/26/15.
//  Copyright © 2015 maquan. All rights reserved.
//

//  ImageTrack 采用个 cache model 优先处理，之后如果有网络就进行服务器处理。

import UIKit
import AVOSCloud
import Kingfisher
import AVFoundation
import NYXImagesKit
import RealmSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias QureyImageTrackDataCompletion = (_ succeed: Bool?) -> Void
typealias QureyImageTrackDataPolicy = (fromCachePriority: Bool, updateCache: Bool )

class ImageTrackViewModel: NSObject {

    var imageTrackModelList: [ImageTrackModel]! = [ImageTrackModel]()           //  存储当前imageTrack的缓存列表
    var realm: Realm = try! Realm()
    
    deinit {
        print("\(type(of: self)) deinit\n")
    }
}

//  MARK: Public
extension ImageTrackViewModel {
    
    /**
     根据imageTrackIdList的id列表创建生成imageTrackDataList
     
     - parameter complete: 完成回调
     */
    func queryImageTrackListCompletion(_ policy: QureyImageTrackDataPolicy = (true, true), complete: QureyImageTrackDataCompletion?)
    {
        var cloudModelList: [ImageTrackModel]?
        var cacheModelList: Results<ImageTrackCacheModel>?
        //  先从数据库取
        if policy.fromCachePriority {
            //  筛选列表中的数据
            cacheModelList = realm.objects(ImageTrackCacheModel.self)
            //  排序 + 格式转换
            if cacheModelList?.count > 0 {
                cloudModelList = cacheModelList!.sorted{
                    return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                }.map {
                    return $0.exportToCloudObject()
                }
                imageTrackModelList = cloudModelList
                complete?(true)
            }
        }
    
        if policy.updateCache || cloudModelList?.count > 0 {
            
            let identifier: String = ImageTrackModel.uniqueIdentifier()
            let query: AVQuery = AVQuery(className: ImageTrackModel.RealClassName)
            query.whereKey("identifier", equalTo: identifier)
    
            query.findObjectsInBackground { [weak self] (objects: [Any]?, error: Swift.Error?) in
                guard let strongSelf = self else { complete?(error == nil); return }
                guard error == nil else { complete?(false); return }
                if var newImageTrackModelList = objects as? [ImageTrackModel] {
                    newImageTrackModelList.sort {
                        return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                    }
                    strongSelf.imageTrackModelList = newImageTrackModelList
                    try! strongSelf.realm.write {
                        strongSelf.realm.delete(cacheModelList ?? strongSelf.realm.objects(ImageTrackCacheModel.self))
                        strongSelf.imageTrackModelList.forEach {
                            strongSelf.realm.add($0.exportToCacheObject(), update: true)
                        }
                    }
                }
                complete?(true)
            }
        }
    }
    
    /**
     传入一张原图，进行云端上传
     
     - parameter progressClosure: 进度回调
     - parameter complete: 完成回调
     */
    func queryAddImageTrackWithOringinImage(_ originImage: UIImage!, progress: ((_ progress: Int) -> Void)?, completion: QureyImageTrackDataCompletion?)
    {
        var isSucceed: Bool = true
        
        typealias SaveImageFileCompletion = (_ succeed: Bool) -> Void
        typealias SaveImageFileClosure = (_ imageFile: AVFile?, _ progress: ((_ progress: Int) -> Void)?, _ completion: SaveImageFileCompletion?) -> Void
        let querySaveImageFile: SaveImageFileClosure = { (imageFile, progress, completion) in
            imageFile!.saveInBackground({ (succeed, error) in
                if succeed {
//                    print("image Url: \(imageFile.url) \n size: \(imageFile.size) \n text: xxx \n image length: \(imageFile.getData().length) size: \(imageFile.size() / 1024) KB")
                    //  很重要,将imageData存到SDImageCache的disk cache中
                    if let image = UIImage(data: imageFile!.getData()!) {
                        ImageCache.default.store(image, forKey: (imageFile?.url)!)
                    }
                    //  将本地的AVCacheFile缓存清理掉
                    imageFile?.clearCachedFile()
                }
                completion?(succeed)
            }, progressBlock: {
                progress?($0)
            })
        }
        
        let saveImageGroup: DispatchGroup = DispatchGroup()
        
        saveImageGroup.enter()
        //  调度组一：上传原图
        let originImageFile: AVFile! = AVFile(name: "maquan", data: UIImageJPEGRepresentation(originImage!, 0))
        querySaveImageFile(originImageFile, progress) { (succeed) in
            if succeed {
                
            }
            else {
                isSucceed = false
            }
            saveImageGroup.leave()
        }
        
        saveImageGroup.enter()
        //  调度组二：上传缩略图
        var thumbImageFile: AVFile?
        if originImage.size.width > 720 {
            let boundingRect = CGRect(x: 0, y: 0, width: 720, height: CGFloat(MAXFLOAT))
            let thumbImageSize = AVMakeRect(aspectRatio: CGSize(width: originImage.size.width, height: originImage.size.height), insideRect: boundingRect).size
            let thumbImage = originImage.scale(to: thumbImageSize)
            thumbImageFile = AVFile(name: "maquan", data: UIImageJPEGRepresentation(thumbImage!, 0))
            querySaveImageFile(thumbImageFile, nil) { (succeed) in
                if succeed {
                
                }
                else {
                    isSucceed = false
                }
                saveImageGroup.leave()
            }
        }
        
        saveImageGroup.notify(queue: DispatchQueue.main) { [weak self] () -> Void in
            guard let _ = self else { completion?(isSucceed); return }
            guard isSucceed == true else { completion?(false); return }
            //  新 imageTrack
            let newImageTrackModel: ImageTrackModel! = ImageTrackModel(objectId: nil,
                                                                       identifier: ImageTrackModel.uniqueIdentifier(),
                                                                       thumbImageFileUrl: thumbImageFile?.url,
                                                                       largeImageFileUrl: nil,
                                                                       originImageFileUrl: originImageFile.url,
                                                                       thumbImageFileObjectId: thumbImageFile?.objectId,
                                                                       largeImageFileObjectId: nil,
                                                                       originImageFileObjectId: originImageFile.objectId,
                                                                       text: nil,
                                                                       imageSize: originImage.size)
            newImageTrackModel.saveInBackground { [weak self] succeed, error in
                guard let strongSelf = self else { completion?(succeed); return }
                if succeed {
                    strongSelf.imageTrackModelList.insert(newImageTrackModel, at: 0)
                    try! strongSelf.realm.write {
                        strongSelf.realm.add(newImageTrackModel!.exportToCacheObject())
                    }
                }
                completion?(isSucceed)
            }
        }
    }
    
    func queryDeleteImageTrackAtIndex(_ index: Int!, complete: QureyImageTrackDataCompletion?)
    {
        guard let trackModel = fetchImageTrackModelWithIndex(index) else { complete?(false); return }
        trackModel.deleteInBackground { [weak self] (succeed, error) in
            guard let strongSelf = self else { complete?(false); return }
            if succeed {
                strongSelf.imageTrackModelList.remove(at: index)
                
                try! strongSelf.realm.write {
                    let deleteObj: [ImageTrackCacheModel] = strongSelf.realm.objects(ImageTrackCacheModel.self).filter { $0.objectId == trackModel.objectId
                    }
                    strongSelf.realm.delete(deleteObj)
                }
                
                //  删除原图
                let originImageFile = AVFile()
                originImageFile.objectId = trackModel.originImageFileObjectId
                originImageFile.deleteInBackground { (success, error) -> Void in
                    print(success)
                }
                
                //  删除缩略图
                if trackModel.thumbImageFileUrl != trackModel.originImageFileUrl {
                    let thumbImageFile = AVFile()
                    thumbImageFile.objectId = trackModel.thumbImageFileObjectId
                    thumbImageFile.deleteInBackground { (success, error) -> Void in
                        print(success)
                    }
                }
                //  删除大图
                if trackModel.largeImageFileUrl != trackModel.originImageFileUrl {
                    let largeImageFile = AVFile()
                    largeImageFile.objectId = trackModel.largeImageFileObjectId
                    largeImageFile.deleteInBackground { (success, error) -> Void in
                        print(success)
                    }
                }
            }
            complete?(succeed)
        }
    }
    
    /**
    从缓存中取某条图文迹
    
    - parameter index: 下标号
    - returns: 图文迹Model
    */
    func fetchImageTrackModelWithIndex(_ index: Int!) -> ImageTrackModel?
    {
        return imageTrackModelList[index]
    }
    
}
