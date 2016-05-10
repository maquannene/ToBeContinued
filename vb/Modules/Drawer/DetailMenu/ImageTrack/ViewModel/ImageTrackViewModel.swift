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
import SDWebImage
import AVFoundation
import NYXImagesKit
import RealmSwift

typealias QureyImageTrackDataCompletion = (succeed: Bool!) -> Void
typealias QureyImageTrackDataPolicy = (fromCachePriority: Bool, updateCache: Bool )

class ImageTrackViewModel: NSObject {

    var imageTrackIdList: ImageTrackIdListModel?
    var imageTrackList: [ImageTrackModel?]! = [ImageTrackModel?]()           //  存储当前imageTrack的缓存列表
    let realm: Realm = try! Realm()
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
}

//  MARK: Public
extension ImageTrackViewModel {
    
    /**
    请求获取包含每个imageTrack对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryFindImageTrackIdListCompletion(policy: QureyImageTrackDataPolicy = (true, true), complete: QureyImageTrackDataCompletion?)
    {
        //  先从数据库取
        var cacheModel: ImageTrackIdListModel?
        if policy.fromCachePriority {
            if let cacheResults: Results = realm.objects(ImageTrackIdListCacheModel) {
                if cacheResults.count > 0 {
                    cacheModel = cacheResults[0].exportToCloudObject()
                    imageTrackIdList = cacheModel
                    complete?(succeed: true)
                }
            }
        }
        
        //  再从服务器拉取
        if policy.updateCache || cacheModel == nil {
            let identifier:  String = ImageTrackIdListModel.uniqueIdentifier()
            let query: AVQuery = AVQuery(className: ImageTrackIdListModel.RealClassName)
            query.whereKey("identifier", equalTo: identifier)
            query.findObjectsInBackgroundWithBlock { [weak self] (object: [AnyObject]!, error: NSError!) -> Void in
                guard let strongSelf = self else { complete?(succeed: false); return }
                if let objc = object[0] as? ImageTrackIdListModel {
                    strongSelf.imageTrackIdList = objc
                    try! strongSelf.realm.write {
                        strongSelf.realm.add(objc.exportToCacheObject(), update: true)
                    }
                    complete?(succeed: true)
                }
                complete?(succeed: false)
            }
        }
    }
    
    /**
     根据imageTrackIdList的id列表创建生成imageTrackDataList
     
     - parameter complete: 完成回调
     */
    func queryImageTrackListCompletion(policy: QureyImageTrackDataPolicy = (true, true), complete: QureyImageTrackDataCompletion?)
    {
        var cloudModelList: [ImageTrackModel?]?
        //  先从数据库取
        if policy.fromCachePriority {
            //  筛选列表中的数据
            let filterCacheModelList = realm.objects(ImageTrackCacheModel).filter{ (model) -> Bool in
                for i in (imageTrackIdList?.list)! {
                    if model.objectId == i {
                        return true
                    }
                }
                //  冗余数据清理
                try! realm.write {
                    if let deleteObject: [ImageTrackId] = realm.objects(ImageTrackId).filter( { $0.id == model.objectId }) {
                        realm.delete(deleteObject[0])   //  清除冗余的 id
                    }
                    realm.delete(model) //  清除冗余的 cacheModel
                }
                return false
            }
            //  排序 + 格式转换
            if filterCacheModelList.count > 0 {
                cloudModelList = filterCacheModelList.sort{
                    return $0.createdAt.timeIntervalSince1970 < $1.createdAt.timeIntervalSince1970
                }.map {
                    return $0.exportToCloudObject()
                }
                imageTrackList = cloudModelList
                complete?(succeed: true)
            }
        }
    
        if policy.updateCache || cloudModelList?.count > 0 {
            let fetchGroup: dispatch_group_t = dispatch_group_create()
            var newImageTrackList = [ImageTrackModel?]()
            var succeed = true      //  加载标志位，一旦有一个失败，就标记失败
            for objectId in imageTrackIdList!.list {
                dispatch_group_enter(fetchGroup)
                let imageTrack: ImageTrackModel = ImageTrackModel(outDataWithObjectId: objectId)
                imageTrack.fetchInBackgroundWithBlock{ [unowned imageTrack] (object, error) -> Void in
                    if error != nil {
                        succeed = false
                    }
                    else {
                        newImageTrackList.insert(imageTrack, atIndex: 0)
                    }
                    dispatch_group_leave(fetchGroup)
                }
            }
            dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) { [weak self] () -> Void in
                guard let strongSelf = self else { complete?(succeed: succeed); return }
                if succeed == true {
                    if newImageTrackList.count > 2 {
                        //  对数据根据时间进行排序
                        newImageTrackList.sortInPlace {
                            return $0!.createdAt.timeIntervalSince1970 < $1!.createdAt.timeIntervalSince1970
                        }
                    }
                    strongSelf.imageTrackList = newImageTrackList
                    try! strongSelf.realm.write {
                        strongSelf.imageTrackList.forEach {
                            strongSelf.realm.add($0!.exportToCacheObject())
                        }
                    }
                }
                complete?(succeed: succeed)
            }
        }
    }

    /**
    第一次使用 请求图文迹列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreateImageTrackIdListCompletion(complete: QureyImageTrackDataCompletion?)
    {
        let identifier: String = ImageTrackIdListModel.uniqueIdentifier()
        let cloudModel = ImageTrackIdListModel(identifier: identifier)
        //  写服务器数据
        cloudModel.saveInBackgroundWithBlock{ [weak self] (succeed, error) -> Void in
            guard let sSelf = self else { complete?(succeed: succeed); return }
            if succeed {
                sSelf.imageTrackIdList = cloudModel
                //  写数据库数据
                try! sSelf.realm.write {
                    sSelf.realm.add(sSelf.imageTrackIdList!.exportToCacheObject(), update: true)
                }
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
     传入一张原图，进行云端上传
     
     - parameter progressClosure: 进度回调
     - parameter complete: 完成回调
     */
    func queryAddImageTrackWithOringinImage(originImage: UIImage!, progressClosure: ((progress: Int) -> Void)?, complete: QureyImageTrackDataCompletion?)
    {
        typealias saveImageFileClosure = (imageFile: AVFile!, group: dispatch_group_t!, progressClosure: ((progress: Int) -> Void)?, complete: QureyImageTrackDataCompletion?) -> Void
        let querySaveImageFile: saveImageFileClosure = { (imageFile, group, progressClosure, complete) in
            dispatch_group_enter(group)
            imageFile.saveInBackgroundWithBlock({ [weak imageFile] (succeed, error) -> Void in
                guard succeed == true else { complete?(succeed: false); return }    //  确保上传图片成功
                guard let weakimageFile = imageFile else { return }
//                print("image Url: \(weakimageFile.url) \n size: \(image.size) \n text: xxx \n image length: \(weakimageFile.getData().length) size: \(weakimageFile.size() / 1024) KB")
                //  很重要,将imageData存到SDImageCache的disk cache中
                NSFileManager.defaultManager().createFileAtPath(SDImageCache.sharedImageCache().defaultCachePathForKey(weakimageFile.url), contents: weakimageFile.getData(), attributes: nil)
                //  将本地的AVCacheFile缓存清理掉
                weakimageFile.clearCachedFile()
                dispatch_group_leave(group)
            }, progressBlock: { (progress: Int) -> Void in
                    progressClosure?(progress: progress)
            })
        }
        
        let saveImageGroup: dispatch_group_t = dispatch_group_create()

        //  调度组一：上传原图
        let originImageFile: AVFile! = AVFile(name: "maquan", data: UIImageJPEGRepresentation(originImage!, 0))
        querySaveImageFile(imageFile: originImageFile, group: saveImageGroup, progressClosure: progressClosure, complete: complete)

        //  调度组二：上传缩略图
        var thumbImageFile: AVFile?
        if originImage.size.width > 720 {
            let boundingRect = CGRect(x: 0, y: 0, width: 720, height: CGFloat(MAXFLOAT))
            let thumbImageSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: originImage.size.width, height: originImage.size.height), boundingRect).size
            let thumbImage = originImage.scaleToSize(thumbImageSize)
            thumbImageFile = AVFile(name: "maquan", data: UIImageJPEGRepresentation(thumbImage!, 0))
            querySaveImageFile(imageFile: thumbImageFile, group: saveImageGroup, progressClosure: nil, complete: complete)
        }
        
        //  调度组三：上传大图（目前大图就是原图）
        var largeImageFile: AVFile?
        if false {
            let boundingRect = CGRect(x: 0, y: 0, width: 720, height: CGFloat(MAXFLOAT))
            let largeImageSize = AVMakeRectWithAspectRatioInsideRect(CGSize(width: originImage.size.width, height: originImage.size.height), boundingRect).size
            let largeImage = originImage.scaleToSize(largeImageSize)
            largeImageFile = AVFile(name: "maquan", data: UIImageJPEGRepresentation(largeImage!, 0))
            querySaveImageFile(imageFile: largeImageFile, group: saveImageGroup, progressClosure: nil, complete: complete)
        }
        
        dispatch_group_notify(saveImageGroup, dispatch_get_main_queue()) { () -> Void in
            let textTrackModel: ImageTrackModel = ImageTrackModel(thumbImageFileUrl: thumbImageFile?.url, largeImageFileUrl: largeImageFile?.url, originImageFileUrl: originImageFile.url, thumbImageFileObjectId: thumbImageFile?.objectId, largeImageFileObjectId: largeImageFile?.objectId, originImageFileObjectId: originImageFile.objectId, text: nil, imageSize: originImage.size)
            
            textTrackModel.saveInBackgroundWithBlock { [weak self, weak textTrackModel] succeed, error in
                guard succeed == true else { complete?(succeed: false); return }    //  确保成功
                guard let strongSelf = self else { return }
                guard let strongTextTrackModel = textTrackModel else { return }
                guard succeed == true else { complete?(succeed: false); return }
                //  存储完track后 先将对应的id存入imageTrackIdList并且保存
                strongSelf.imageTrackIdList!.addObject(strongTextTrackModel.objectId, forKey: "list")
                strongSelf.imageTrackIdList!.fetchWhenSave = true //  保存的同时获取最新值
                strongSelf.imageTrackIdList!.save()
                //  再将新建track加入缓存中
                strongSelf.imageTrackList.insert(strongTextTrackModel, atIndex: 0)
                complete?(succeed: true)
            }
        }
    }
    
    func queryDeleteImageTrackAtIndex(index: Int!, complete: QureyImageTrackDataCompletion?)
    {
        guard let track = fetchImageTrackModelWithIndex(index) else { complete?(succeed: false); return }
        let newImageTrackIdList: ImageTrackIdListModel = imageTrackIdList?.mutableCopy() as! ImageTrackIdListModel
        newImageTrackIdList.removeObject(track.objectId, forKey: "list")
        newImageTrackIdList.fetchWhenSave = true
        newImageTrackIdList.saveInBackgroundWithBlock { [weak self] (succeed, error) in
            guard let strongSelf = self else { complete?(succeed: false); return }
            if succeed {
                strongSelf.imageTrackIdList = newImageTrackIdList
                strongSelf.imageTrackList.removeAtIndex(index)
                try! strongSelf.realm.write {
                    strongSelf.realm.add(strongSelf.imageTrackIdList!.exportToCacheObject(), update: true)
                    if let deleteIdObj: [ImageTrackId] = strongSelf.realm.objects(ImageTrackId).filter( { $0.id == track.objectId } ) {
                        strongSelf.realm.delete(deleteIdObj)
                    }
                    if let deleteObj: [ImageTrackCacheModel] = strongSelf.realm.objects(ImageTrackCacheModel).filter( { $0.objectId == track.objectId } ) {
                        strongSelf.realm.delete(deleteObj)
                    }
                }
                //  删除原图
                let originImageFile = AVFile()
                originImageFile.objectId = track.originImageFileObjectId
                originImageFile.deleteInBackgroundWithBlock { (success, error) -> Void in
                    print(success)
                }
                
                //  删除缩略图
                if track.thumbImageFileUrl != track.originImageFileUrl {
                    let thumbImageFile = AVFile()
                    thumbImageFile.objectId = track.thumbImageFileObjectId
                    thumbImageFile.deleteInBackgroundWithBlock { (success, error) -> Void in
                        print(success)
                    }
                }
                //  删除大图
                if track.largeImageFileUrl != track.originImageFileUrl {
                    let largeImageFile = AVFile()
                    largeImageFile.objectId = track.largeImageFileObjectId
                    largeImageFile.deleteInBackgroundWithBlock { (success, error) -> Void in
                        print(success)
                    }
                }
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
    从缓存中取某条图文迹
    
    - parameter index: 下标号
    - returns: 图文迹Model
    */
    func fetchImageTrackModelWithIndex(index: Int!) -> ImageTrackModel?
    {
        return imageTrackList[index]
    }
    
}
