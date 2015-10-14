//
//  MVBImageTextTrackDataSource.swift
//  vb
//
//  Created by 马权 on 9/26/15.
//  Copyright © 2015 maquan. All rights reserved.
//

import UIKit

class MVBImageTextTrackDataSource: NSObject {

    var imageTextTrackIdList: MVBImageTextTrackIdListModel?
    lazy var imageTextTrackList: NSMutableArray = NSMutableArray()          //  存储当前imageTextTrack的缓存列表
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
    
}

//  MARK: Public
extension MVBImageTextTrackDataSource {
    
    /**
    请求获取包含每个imageTextTrack对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryFindImageTextTrackIdList(complete: MVBQureyDataCompleteClosure?) {
        let identifier: String = MVBAppDelegate.MVBApp().uniqueCloudKey! + NSStringFromClass(MVBImageTextTrackIdListModel.self)
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
    func queryCreateImageTextTrackIdList(complete: MVBQureyDataCompleteClosure?) {
        let identifier: String = MVBAppDelegate.MVBApp().uniqueCloudKey! + NSStringFromClass(MVBImageTextTrackIdListModel.self)
        imageTextTrackIdList = MVBImageTextTrackIdListModel(identifier: identifier)
        imageTextTrackIdList!.saveInBackgroundWithBlock{ (succeed, error) -> Void in
            complete?(succeed: succeed.boolValue)
        }
    }
    
    /**
    根据imageTextTrackIdList的id列表创建生成imageTextTrackDataList
    
    - parameter complete: 完成回调
    */
    func queryImageTextTrackList(complete: MVBQureyDataCompleteClosure?) {
        let fetchGroup: dispatch_group_t = dispatch_group_create()
        let newImageTextTrackList = NSMutableArray()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in imageTextTrackIdList!.list {
            dispatch_group_enter(fetchGroup)
            let imageTextTrack: MVBImageTextTrackModel = MVBImageTextTrackModel(withoutDataWithObjectId: objectId as! String)
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
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), { () -> Void in
            if success == true {
                //  对数据根据时间进行排序
                newImageTextTrackList.sortUsingComparator {
                    return ($1 as! MVBImageTextTrackModel).createdAt.compare(($0 as! MVBImageTextTrackModel).createdAt)
                }
            }
            self.imageTextTrackList = newImageTextTrackList
            complete?(succeed: success)
        })
    }
    
    func queryAddImageTextTrack(track: MVBImageTextTrackModel, complete: MVBQureyDataCompleteClosure?) {
        track.saveInBackgroundWithBlock { [weak self] succeed, error in
            guard let strongSelf = self else { return }
            guard succeed.boolValue == true else { complete?(succeed: false); return }
            //  存储完track后 先将对应的id存入imageTextTrackIdList并且保存
            strongSelf.imageTextTrackIdList!.addObject(track.objectId, forKey: "list")
            strongSelf.imageTextTrackIdList!.fetchWhenSave = true //  保存的同时获取最新值
            strongSelf.imageTextTrackIdList!.save()
            //  再将新建track加入缓存中
            strongSelf.imageTextTrackList.insertObject(track, atIndex: 0)
            complete?(succeed: succeed)
        }
    }
    
}
