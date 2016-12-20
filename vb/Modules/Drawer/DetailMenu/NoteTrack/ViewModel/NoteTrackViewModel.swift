//
//  NoteTrackViewModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
 
import AVOSCloud
import RealmSwift
  
typealias QureyNoteTrackDataCompletion = (_ succeed: Bool?) -> Void
  
class NoteTrackViewModel: NSObject {
    
//    var noteTrackIdList: NoteTrackIdListModel?
    var noteTrackModelList: [NoteTrackModel]! = [NoteTrackModel]()            //  存储noteModel列表的缓存数组
    let realm: Realm = try! Realm()
    
    var expandingIndexPath: IndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: IndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(type(of: self)) deinit\n")
    }
}

//  MARK: Public
extension NoteTrackViewModel {
    
    /**
     根据 noteTrackIdList 的 id 列表重新生成 noteTrackModelList
     
     - parameter complete: 完成回调
     */
    func queryNoteTrackListCompletion(_ fromCachePriority: Bool = true, updateCache: Bool = true, complete: QureyNoteTrackDataCompletion?)
    {
        var cloudModelList: [NoteTrackModel]?
        var cacheModelList: Results<NoteTrackCacheModel>?
        //  先从数据库取
        if fromCachePriority {
            //  筛选列表中的数据
            cacheModelList = realm.objects(NoteTrackCacheModel.self)
            //  排序 + 格式转换
            if (cacheModelList?.count)! > 0 {
                cloudModelList = cacheModelList?.sorted {
                    return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                }.map {
                    $0.exportToCloudObject()
                }
                noteTrackModelList = cloudModelList
                complete?(true)
            }
        }
        
        if updateCache || cloudModelList == nil {
            let identifier: String = NoteTrackModel.uniqueIdentifier()
            let query: AVQuery = AVQuery(className: NoteTrackModel.RealClassName)
            //  根据identifier 识别符查询list
            query.whereKey("identifier", equalTo: identifier)
            query.findObjectsInBackground { [weak self] (objects: [Any]?, error: Swift.Error?) in
                guard let strongSelf = self else { complete?(error == nil); return }
                guard error == nil else { complete?(false); return }
                if var newNoteTrackModelList = objects as? [NoteTrackModel] {
                    if newNoteTrackModelList.count > 1 {
                        newNoteTrackModelList.sort {
                            return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                        }
                    }
                    strongSelf.noteTrackModelList = newNoteTrackModelList
                    try! strongSelf.realm.write {
                        strongSelf.realm.delete(cacheModelList ?? strongSelf.realm.objects(NoteTrackCacheModel.self.self))
                        strongSelf.noteTrackModelList.forEach {
                            strongSelf.realm.add($0.exportToCacheObject(), update: true)
                        }
                    }
                }
                complete?(true)
            }
        }
    }

    /**
    请求新增 NoteTrack 对象
    
    - parameter noteTrackModel:   NoteTrack 对象
    - parameter complete: 完成回调
    */
    func queryAddNoteTrack(_ newNoteTrackModel: NoteTrackModel, complete: QureyNoteTrackDataCompletion?)
    {
        newNoteTrackModel.identifier = NoteTrackModel.uniqueIdentifier()
        newNoteTrackModel.saveInBackground { [weak self] (succeed: Bool, error: Swift.Error?) -> Void in
            guard let sSelf = self else { complete?(succeed); return }
            if  (succeed) {
                //  写数据库数据
                sSelf.noteTrackModelList.insert(newNoteTrackModel, at: 0)
                try! sSelf.realm.write {
                    sSelf.realm.add(newNoteTrackModel.exportToCacheObject(), update: true)
                }
            }
            complete?(succeed)
        }
    }
    
    /**
    请求删除 NoteTrack 对象
    
    - parameter index:    要删除的index
    - parameter complete: 删除完成回调
    */
    func queryDeleteNoteTrackAtIndex(_ index: Int!, complete: QureyNoteTrackDataCompletion?)
    {
        guard let trackModel = fetchNoteTrackModel(index) else { complete?(false); return }
    
        trackModel.deleteInBackground { [weak self] (succeed, error) in
            guard let strongSelf = self else { complete?(succeed); return }
            if succeed {
                strongSelf.noteTrackModelList.remove(at: index)
                //  删除数据库中 NoteTrackCacheModel 对象
                let deleteObj: [NoteTrackCacheModel] = strongSelf.realm.objects(NoteTrackCacheModel.self).filter {
                    $0.objectId == trackModel.objectId
                }
                try! strongSelf.realm.write {
                    strongSelf.realm.delete(deleteObj)
                }
            }
            complete?(succeed)
        }
    }
    
    /**
    请求更新 NoteTrack 对象
    
    - parameter track:   需要更新的密码对象
    - parameter complete: 完成回调
    */
    func queryUpdateNoteTrack(_ newNoteTrackModel: NoteTrackModel, index: Int, complete: QureyNoteTrackDataCompletion?)
    {
        newNoteTrackModel.saveInBackground { [weak self] (succeed: Bool, error: Swift.Error?) -> Void in
            guard let sSelf = self else { return }
            if (succeed) {
                if let noteTrackModel = sSelf.noteTrackModelList[index] as NoteTrackModel? {
                    noteTrackModel.update(newTrackModel: newNoteTrackModel)
                    try! sSelf.realm.write {
                        sSelf.realm.add(noteTrackModel.exportToCacheObject(), update: true)
                    }
                }
            }
            complete?(succeed)
        }
    }
    
    /**
    从缓存中取某条 NoteTrack 对象
    
    - parameter index: 下标号
    - returns: NoteTrackModel对象
    */
    func fetchNoteTrackModel(_ index: Int!) -> NoteTrackModel?
    {
        return noteTrackModelList[index]
    }

    func convertToActualIndexPath(_ indexPath: IndexPath) -> IndexPath!
    {
        if (expandedIndexPath != nil && indexPath.row >= expandedIndexPath!.row) {
            return IndexPath(row: indexPath.row - 1, section: indexPath.section)
        }
        return indexPath
    }

}

  
