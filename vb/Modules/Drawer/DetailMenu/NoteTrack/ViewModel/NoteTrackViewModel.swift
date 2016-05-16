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
    
//    var noteTrackIdList: NoteTrackIdListModel?
    var noteTrackModelList: [NoteTrackModel]! = [NoteTrackModel]()            //  存储noteModel列表的缓存数组
    let realm: Realm = try! Realm()
    
    var expandingIndexPath: NSIndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: NSIndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
}

//  MARK: Public
extension NoteTrackViewModel {
    
    /**
     根据 noteTrackIdList 的 id 列表重新生成 noteTrackModelList
     
     - parameter complete: 完成回调
     */
    func queryNoteTrackListCompletion(fromCachePriority: Bool = true, updateCache: Bool = true, complete: QureyNoteTrackDataCompletion?)
    {
        var cloudModelList: [NoteTrackModel]?
        var cacheModelList: Results<NoteTrackCacheModel>?
        //  先从数据库取
        if fromCachePriority {
            //  筛选列表中的数据
            cacheModelList = realm.objects(NoteTrackCacheModel)
            //  排序 + 格式转换
            if cacheModelList?.count > 0 {
                cloudModelList = cacheModelList?.sort {
                    return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                }.map {
                    $0.exportToCloudObject()
                }
                noteTrackModelList = cloudModelList
                complete?(succeed: true)
            }
        }
        
        if updateCache || cloudModelList == nil {
            let identifier: String = NoteTrackModel.uniqueIdentifier()
            let query: AVQuery = AVQuery(className: NoteTrackModel.RealClassName)
            //  根据identifier 识别符查询list
            query.whereKey("identifier", equalTo: identifier)
            query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]!, error) in
                guard let strongSelf = self else { complete?(succeed: error == nil); return }
                guard error == nil else { print(error); complete?(succeed: false); return }
                if var newNoteTrackModelList = objects as? [NoteTrackModel] {
                    if newNoteTrackModelList.count > 1 {
                        newNoteTrackModelList.sortInPlace {
                            return $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
                        }
                    }
                    strongSelf.noteTrackModelList = newNoteTrackModelList
                    try! strongSelf.realm.write {
                        strongSelf.realm.delete(cacheModelList ?? strongSelf.realm.objects(NoteTrackCacheModel))
                        strongSelf.noteTrackModelList.forEach {
                            strongSelf.realm.add($0.exportToCacheObject(), update: true)
                        }
                    }
                }
                complete?(succeed: true)
            }
        }
    }

    /**
    请求新增 NoteTrack 对象
    
    - parameter noteTrackModel:   NoteTrack 对象
    - parameter complete: 完成回调
    */
    func queryAddNoteTrack(newNoteTrackModel: NoteTrackModel, complete: QureyNoteTrackDataCompletion?)
    {
        newNoteTrackModel.identifier = NoteTrackModel.uniqueIdentifier()
        newNoteTrackModel.saveInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) -> Void in
            guard let sSelf = self else { complete?(succeed: succeed); return }
            if  (succeed) {
                //  写数据库数据
                sSelf.noteTrackModelList.insert(newNoteTrackModel, atIndex: 0)
                try! sSelf.realm.write {
                    sSelf.realm.add(newNoteTrackModel.exportToCacheObject(), update: true)
                }
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求删除 NoteTrack 对象
    
    - parameter index:    要删除的index
    - parameter complete: 删除完成回调
    */
    func queryDeleteNoteTrackAtIndex(index: Int!, complete: QureyNoteTrackDataCompletion?)
    {
        guard let trackModel = fetchNoteTrackModel(index) else { complete?(succeed: false); return }
    
        trackModel.deleteInBackgroundWithBlock { [weak self] (succeed, error) in
            guard let strongSelf = self else { complete?(succeed: succeed); return }
            if succeed {
                strongSelf.noteTrackModelList.removeAtIndex(index)
                //  删除数据库中 NoteTrackCacheModel 对象
                if let deleteObj: [NoteTrackCacheModel] = strongSelf.realm.objects(NoteTrackCacheModel).filter( {$0.objectId == trackModel.objectId } ) {
                    try! strongSelf.realm.write {
                        strongSelf.realm.delete(deleteObj)
                    }
                }
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求更新 NoteTrack 对象
    
    - parameter track:   需要更新的密码对象
    - parameter complete: 完成回调
    */
    func queryUpdateNoteTrack(newNoteTrackModel: NoteTrackModel, index: Int, complete: QureyNoteTrackDataCompletion?)
    {
        newNoteTrackModel.saveInBackgroundWithBlock { [weak self] (succeed: Bool, error: NSError!) -> Void in
            guard let sSelf = self else { return }
            if (succeed) {
                if let noteTrackModel = sSelf.noteTrackModelList[index] as NoteTrackModel? {
                    noteTrackModel.update(newTrackModel: newNoteTrackModel)
                    try! sSelf.realm.write {
                        sSelf.realm.add(noteTrackModel.exportToCacheObject(), update: true)
                    }
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

  