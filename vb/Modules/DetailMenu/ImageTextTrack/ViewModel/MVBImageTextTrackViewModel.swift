//
//  MVBImageTextTrackViewModel.swift
//  vb
//
//  Created by 马权 on 9/26/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit
import AVOSCloud
import SDWebImage
import AVFoundation
import NYXImagesKit

class MVBImageTextTrackViewModel: NSObject {

    var imageTextTrackIdList: MVBImageTextTrackIdListModel?
    lazy var imageTextTrackList: NSMutableArray = NSMutableArray()          //  存储当前imageTextTrack的缓存列表
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
    
}

//  MARK: Public
extension MVBImageTextTrackViewModel {
    
    /**
    请求获取包含每个imageTextTrack对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryFindImageTextTrackIdListCompletion(complete: MVBQureyDataCompleteClosure?)
    {
        let identifier: String = UserInfoManange.shareInstance.uniqueCloudKey! + NSStringFromClass(MVBImageTextTrackIdListModel.self)
        let query: AVQuery = AVQuery(className: MVBImageTextTrackIdListModel.ClassName)
        //  根据identifier 识别符查询list
        query.whereKey("identifier", equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]!, error) -> Void in
            guard let strongSelf = self else { return }
            guard error == nil else { complete?(succeed: false); return }
            guard objects != nil && objects.count > 0 else { complete?(succeed: false); return }
            guard let objc = objects[0] as? MVBImageTextTrackIdListModel else { complete?(succeed: false); return }
            strongSelf.imageTextTrackIdList = objc
            complete?(succeed: true)
        }
    }
    
    /**
    第一次使用 请求图文迹列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreateImageTextTrackIdListCompletion(complete: MVBQureyDataCompleteClosure?)
    {
        let identifier: String = UserInfoManange.shareInstance.uniqueCloudKey! + NSStringFromClass(MVBImageTextTrackIdListModel.self)
        imageTextTrackIdList = MVBImageTextTrackIdListModel(identifier: identifier)
        imageTextTrackIdList!.saveInBackgroundWithBlock{ (succeed, error) -> Void in
            complete?(succeed: succeed)
        }
    }
    
    /**
    根据imageTextTrackIdList的id列表创建生成imageTextTrackDataList
    
    - parameter complete: 完成回调
    */
    func queryImageTextTrackListCompletion(complete: MVBQureyDataCompleteClosure?)
    {
        let fetchGroup: dispatch_group_t = dispatch_group_create()
        let newImageTextTrackList = NSMutableArray()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in imageTextTrackIdList!.list {
            dispatch_group_enter(fetchGroup)
            let imageTextTrack: MVBImageTextTrackModel = MVBImageTextTrackModel(outDataWithObjectId: objectId as! String)
            imageTextTrack.fetchInBackgroundWithBlock{ [weak imageTextTrack] (object, error) -> Void in
                guard let weakImageTextTrack = imageTextTrack else { return }
                if error != nil {
                    success = false
                }
                else {
                    newImageTextTrackList.addObject(weakImageTextTrack)
                }
                dispatch_group_leave(fetchGroup)
            }
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) { () -> Void in
            if success == true {
                //  对数据根据时间进行排序
                newImageTextTrackList.sortUsingComparator {
                    return ($1 as! MVBImageTextTrackModel).createdAt.compare(($0 as! MVBImageTextTrackModel).createdAt)
                }
            }
            self.imageTextTrackList = newImageTextTrackList
            complete?(succeed: success)
        }
    }

    /**
     传入一张原图，进行云端上传
     
     - parameter progressClosure: 进度回调
     - parameter complete: 完成回调
     */
    func queryAddImageTextTrackWithOringinImage(originImage: UIImage!, progressClosure: ((progress: Int) -> Void)?, complete: MVBQureyDataCompleteClosure?)
    {
        typealias saveImageFileClosure = (imageFile: AVFile!, group: dispatch_group_t!, progressClosure: ((progress: Int) -> Void)?, complete: MVBQureyDataCompleteClosure?) -> Void
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
            let textTrackModel: MVBImageTextTrackModel = MVBImageTextTrackModel(thumbImageFileUrl: thumbImageFile?.url, largeImageFileUrl: largeImageFile?.url, originImageFileUrl: originImageFile.url, thumbImageFileObjectId: thumbImageFile?.objectId, largeImageFileObjectId: largeImageFile?.objectId, originImageFileObjectId: originImageFile.objectId, text: nil, imageSize: originImage.size)
            
            textTrackModel.saveInBackgroundWithBlock { [weak self, weak textTrackModel] succeed, error in
                guard succeed == true else { complete?(succeed: false); return }    //  确保成功
                guard let strongSelf = self else { return }
                guard let strongTextTrackModel = textTrackModel else { return }
                guard succeed == true else { complete?(succeed: false); return }
                //  存储完track后 先将对应的id存入imageTextTrackIdList并且保存
                strongSelf.imageTextTrackIdList!.addObject(strongTextTrackModel.objectId, forKey: "list")
                strongSelf.imageTextTrackIdList!.fetchWhenSave = true //  保存的同时获取最新值
                strongSelf.imageTextTrackIdList!.save()
                //  再将新建track加入缓存中
                strongSelf.imageTextTrackList.insertObject(strongTextTrackModel, atIndex: 0)
                complete?(succeed: true)
            }
        }
    }
    
    func queryDeleteImageTextTrackAtIndex(index: Int!, complete: MVBQureyDataCompleteClosure?)
    {
        let track: MVBImageTextTrackModel! = fetchImageTextTrackModelWithIndex(index)
        
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
        track.deleteInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) -> Void in
            guard let strongSelf = self else { return }
            guard succeed == true else { complete?(succeed: false); return }
            //  删除成功后要将密码记录的objectId从noteTrackIdLis中删除并保存
            strongSelf.imageTextTrackIdList!.removeObject(track.objectId, forKey: "list")
            strongSelf.imageTextTrackIdList!.fetchWhenSave = true //  保存的同时获取最新值
            strongSelf.imageTextTrackIdList!.save()
            //  将要删除的track从缓存中删除
            strongSelf.imageTextTrackList.removeObjectAtIndex(index)
            complete?(succeed: succeed)
        }
    }
    
    /**
    从缓存中取某条图文迹
    
    - parameter index: 下标号
    - returns: 图文迹Model
    */
    func fetchImageTextTrackModelWithIndex(index: Int!) -> MVBImageTextTrackModel!
    {
        return imageTextTrackList[index] as! MVBImageTextTrackModel
    }
    
}
