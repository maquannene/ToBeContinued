//
//  NoteTrackViewModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
 
import AVOSCloud
import RealmSwift
  
typealias QureyNoteTrackDataCompletion = (succeed: Bool!) -> Void
  
class NoteTrackViewModel: NSObject {
    
    var noteTrackIdList: NoteTrackIdListModel?
    var noteTrackModelList: [NoteTrackModel]! = [NoteTrackModel]()              //  存储noteModel列表的缓存数组
    lazy var realm: Realm? = try! Realm()
    
    var expandingIndexPath: NSIndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: NSIndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
}

//  MARK: Public
extension NoteTrackViewModel: CloudModelBase {
    
    /**
    请求查找包含每个 NoteTrack 对象objectId的列表
    
    - parameter complete: 完成回调
    */
    func queryFindNoteTrackIdListCompletion(fromCachePriority: Bool = true, updateCache: Bool = true, complete: QureyNoteTrackDataCompletion?)
    {
        //  先从数据库取
        var cacheModel: NoteTrackIdListModel?
        if fromCachePriority {
            if let cacheResults: Results = realm?.objects(NoteTrackIdListCacheModel) {
                if cacheResults.count > 0 {
                    cacheModel = cacheResults[0].exportToCloudObject()
                    noteTrackIdList = cacheModel
                    complete?(succeed: true)
                }
            }
        }
    
        //  再从服务器取
        if updateCache || cacheModel != nil {
            let identifier: String = NoteTrackViewModel.uniqueIdentifier()
            let query: AVQuery = AVQuery(className: NoteTrackIdListModel.RealClassName)
            //  根据identifier 识别符查询list
            query.whereKey("identifier", equalTo: identifier)
            query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
                guard error == nil else { complete?(succeed: false); return }
                guard objects != nil && objects.count > 0 else { complete?(succeed: false); return }
                guard let objc = objects[0] as? NoteTrackIdListModel else { complete?(succeed: false); return }
                self.noteTrackIdList = objc
                try! self.realm?.write {
                    self.realm?.add(objc.exportToCacheObject(), update: true)
                }
                complete?(succeed: true)
            }
        }
    }
    
    /**
     根据 noteTrackIdList 的 id 列表重新生成 noteTrackModelList
     
     - parameter complete: 完成回调
     */
    func queryNoteTrackListCompletion(fromCachePriority: Bool = true, updateCache: Bool = true, complete: QureyNoteTrackDataCompletion?)
    {
        var cacheNoteTrackModelList: [NoteTrackModel]?
        
        //  先从数据库取
        if fromCachePriority {
           cacheNoteTrackModelList = realm?.objects(NoteTrackCacheModel).filter { (cacheModel) -> Bool in
                for i in (noteTrackIdList?.list)! {
                    if cacheModel.objectId == i {
                        return true
                    }
                }
                //  冗余数据清理
                try! realm?.write {
                    //  删除数据库中的 NoteTrackId RealmString 类型
                    if let deleteIdeObj: [RealmString] = realm?.objects(RealmString).filter( { $0.stringValue == cacheModel.objectId } ) {
                        realm?.delete(deleteIdeObj[0])
                    }
                    //  删除数据库中 NoteTrackCacheModel 对象
                    realm?.delete(cacheModel)
                }
                return false
            }.sort {
                return $0.createdAt.timeIntervalSince1970 < $1.createdAt.timeIntervalSince1970
            }.map {
                $0.exportToCloudObject()
            }
            noteTrackModelList = cacheNoteTrackModelList!
            complete?(succeed: true)
        }
        
        //  再从服务器取
        if updateCache || cacheNoteTrackModelList != nil {
            let fetchGroup: dispatch_group_t = dispatch_group_create()
            var newNoteTrackModelList = [NoteTrackModel]()
            var succeed = true      //  加载标志位，一旦有一个失败，就标记失败
            for objectId in self.noteTrackIdList!.list {
                dispatch_group_enter(fetchGroup)
                let noteTrackModel: NoteTrackModel = NoteTrackModel(outDataWithObjectId: objectId )
                noteTrackModel.fetchInBackgroundWithBlock{ (object, error) -> Void in
                    if error != nil {
                        succeed = false
                    }
                    else {
                        newNoteTrackModelList.insert(noteTrackModel, atIndex: 0)
                    }
                    dispatch_group_leave(fetchGroup)
                }
            }
            dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) { [weak self] in
                guard let sSelf = self else { complete?(succeed: succeed); return }
                //  数量大于 2 时，对数据进行排序
                if succeed == true {
                    if newNoteTrackModelList.count > 2 {
                        newNoteTrackModelList.sortInPlace {
                            return $0.createdAt.timeIntervalSince1970 < $1.createdAt.timeIntervalSince1970
                        }
                    }
                    sSelf.noteTrackModelList = newNoteTrackModelList
                    try! sSelf.realm?.write {
                        sSelf.noteTrackModelList.forEach {
                            sSelf.realm?.add($0.exportToCacheObject(), update: true)
                        }
                    }
                }
                complete?(succeed: succeed)
            }
        }
    }
    
    /**
    第一次使用 请求创建 NoteTrack 列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreateNoteTrackIdListCompletion(complete: QureyNoteTrackDataCompletion?)
    {
        let identifier: String = NoteTrackViewModel.uniqueIdentifier()
        let noteTrackIdList = NoteTrackIdListModel(identifier: identifier)
        //  写服务器数据
        noteTrackIdList.saveInBackgroundWithBlock{ [weak self] (succeed, error) -> Void in
            guard let sSelf = self else { complete?(succeed: succeed); return }
            if succeed {
                sSelf.noteTrackIdList = noteTrackIdList
                //  写数据库数据
                try! sSelf.realm?.write {
                    sSelf.realm?.add(sSelf.noteTrackIdList!.exportToCacheObject(), update: true)
                }
            }
            complete?(succeed: succeed)
        }
    }

    /**
    请求新增 NoteTrack 对象
    
    - parameter noteTrackModel:   NoteTrack 对象
    - parameter complete: 完成回调
    */
    func queryAddNoteTrack(newNoteTrackModel: NoteTrackModel, complete: QureyNoteTrackDataCompletion?)
    {
        let newNoteTrackIdList: NoteTrackIdListModel = noteTrackIdList!.copy() as! NoteTrackIdListModel
        newNoteTrackIdList.fetchWhenSave = true
        //  写服务器数据
        //  1.保存 NotTrackModel 到 Cloud
        newNoteTrackModel.saveInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) -> Void in
            guard let sSelf = self else { complete?(succeed: succeed); return }
            var isSucceed = succeed
            guard isSucceed.boolValue == true else { complete?(succeed: false); return }
            //  写完成功后要再将 NoteTrack 的 objectId 写入noteTrackIdList 并且保存
            newNoteTrackIdList.addObject(newNoteTrackModel.objectId, forKey: "list")
            //  2.保存 NoteTrackIdListModel 到 Cloud
            isSucceed = newNoteTrackIdList.save()
            if  (isSucceed) {
                //  写数据库数据
                sSelf.noteTrackModelList.insert(newNoteTrackModel, atIndex: 0)
                sSelf.noteTrackIdList = newNoteTrackIdList
                try! sSelf.realm?.write {
                    sSelf.realm?.add(newNoteTrackModel.exportToCacheObject(), update: true)
                    sSelf.realm?.add(sSelf.noteTrackIdList!.exportToCacheObject(), update: true)
                }
            }
            complete?(succeed: isSucceed)
        }
    }
    
    /**
    请求删除 NoteTrack 对象
    
    - parameter index:    要删除的index
    - parameter complete: 删除完成回调
    */
    func queryDeleteNoteTrackAtIndex(index: Int!, complete: QureyNoteTrackDataCompletion?)
    {
        guard let track = fetchNoteTrackModel(index) else { return }
        let newNoteTrackIdList: NoteTrackIdListModel = noteTrackIdList!.mutableCopy() as! NoteTrackIdListModel
        newNoteTrackIdList.removeObject(track.objectId, forKey: "list")
        newNoteTrackIdList.fetchWhenSave = true
        newNoteTrackIdList.saveInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) in
            guard let sSelf = self else { return }
            if succeed.boolValue == false { complete?(succeed: false); return }
            sSelf.noteTrackIdList = newNoteTrackIdList
            sSelf.noteTrackModelList.removeAtIndex(index)
            try! sSelf.realm?.write {
                //  更新 NoteTrackIdList 的数据库
                sSelf.realm?.add(sSelf.noteTrackIdList!.exportToCacheObject(), update: true)
                //  删除数据库中的 NoteTrackId RealmString 类型
                if let deleteIdeObj: [RealmString] = sSelf.realm?.objects(RealmString).filter( { $0.stringValue == track.objectId } ) {
                    sSelf.realm?.delete(deleteIdeObj[0])
                }
                //  删除数据库中 NoteTrackCacheModel 对象
                if let deleteObj: [NoteTrackCacheModel] = sSelf.realm?.objects(NoteTrackCacheModel).filter( {$0.objectId == track.objectId } ) {
                    sSelf.realm?.delete(deleteObj[0])
                }
            }
            track.deleteInBackground()
            complete?(succeed: true)
        }
    }
    
    /**
    请求更新 NoteTrack 对象
    
    - parameter track:   需要更新的密码对象
    - parameter complete: 完成回调
    */
    func queryUpdateNoteTrack(noteTrackModel: NoteTrackModel, index: Int, complete: QureyNoteTrackDataCompletion?)
    {
        noteTrackModel.saveInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) -> Void in
            guard let sSelf = self else { return }
            if (succeed) {
                sSelf.noteTrackModelList[index].update(newTrackModel: noteTrackModel)
                try! sSelf.realm?.write {
                    sSelf.realm?.add(sSelf.noteTrackModelList[index].exportToCacheObject(), update: true)
                }
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
    从缓存中取某条 NoteTrack 对象
    
    - parameter index: 下标号
    - returns: NoteTrackModel对象
    */
    func fetchNoteTrackModel(index: Int!) -> NoteTrackModel?
    {
        return noteTrackModelList[index]
    }

    func convertToActualIndexPath(indexPath: NSIndexPath) -> NSIndexPath!
    {
        if (expandedIndexPath != nil && indexPath.row >= expandedIndexPath!.row) {
            return NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        }
        return indexPath
    }
    
}

  