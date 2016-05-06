//
//  NoteTrackViewModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
 
import AVOSCloud
  
typealias QureyNoteTrackDataCompletion = (succeed: Bool!) -> Void
  
class NoteTrackViewModel: NSObject {
    
    var noteTrackIdList: NoteTrackIdListModel?
    lazy var noteTrackModelList: [NoteTrackModel?] = [NoteTrackModel?]()          //  存储noteModel列表的缓存数组
    var expandingIndexPath: NSIndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: NSIndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
    
}

//  MARK: Public
extension NoteTrackViewModel: CloudCache {
    /**
    请求查找包含每个 NoteTrack 对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryFindNoteTrackIdListCompletion(complete: QureyNoteTrackDataCompletion?)
    {
        let identifier: String = generateIdentifier(NoteTrackIdListModel.RealClassName)
        let query: AVQuery = AVQuery(className: NoteTrackIdListModel.RealClassName)
        //  根据identifier 识别符查询list
        query.whereKey("identifier", equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            
            guard error == nil else { complete?(succeed: false); return }
            
            guard objects != nil && objects.count > 0 else { complete?(succeed: false); return }
            
            guard let objc = objects[0] as? NoteTrackIdListModel else { complete?(succeed: false); return }
            
            self.noteTrackIdList = objc
            
            complete?(succeed: true)
        }
    }
    
    /**
    第一次使用 请求创建 NoteTrack 列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreateNoteTrackIdListCompletion(complete: QureyNoteTrackDataCompletion?)
    {
        let identifier: String = generateIdentifier(NoteTrackIdListModel.RealClassName)
        self.noteTrackIdList = NoteTrackIdListModel(identifier: identifier)
        self.noteTrackIdList!.saveInBackgroundWithBlock{ (succeed, error) -> Void in
            complete?(succeed: succeed)
        }
    }
    
    /**
    根据 noteTrackIdList 的 id 列表重新生成 noteTrackModelList
    
    - parameter complete: 完成回调
    */
    func queryNoteTrackListCompletion(complete: QureyNoteTrackDataCompletion?)
    {
        let fetchGroup: dispatch_group_t = dispatch_group_create()
        var newNoteTrackModelList = [NoteTrackModel?]()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in self.noteTrackIdList!.list {
            dispatch_group_enter(fetchGroup)
            let noteTrackModel: NoteTrackModel = NoteTrackModel(outDataWithObjectId: objectId as! String)
            noteTrackModel.fetchInBackgroundWithBlock{ (object, error) -> Void in
                if error != nil {
                    success = false
                }
                else {
                    newNoteTrackModelList.insert(noteTrackModel, atIndex: 0)
                }
                dispatch_group_leave(fetchGroup)
            }
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) { () -> Void in
            //  数量大于 2 时，对数据进行排序
            if success == true && newNoteTrackModelList.count > 2 {
                newNoteTrackModelList.sortInPlace {
                    return $1!.createdAt.timeIntervalSince1970 > $0!.createdAt.timeIntervalSince1970
                }
            }
            self.noteTrackModelList = newNoteTrackModelList
            complete?(succeed: success)
        }
    }
    
    /**
    请求新增 NoteTrack 对象
    
    - parameter noteTrackModel:   NoteTrack 对象
    - parameter complete: 完成回调
    */
    func queryAddNoteTrack(noteTrackModel: NoteTrackModel, complete: QureyNoteTrackDataCompletion?)
    {
        //  将新的密码记录写入AVOSCloud
        noteTrackModel.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            var isSucceed = succeed
            guard isSucceed.boolValue == true else { complete?(succeed: false); return }
            //  写完成功后要再将 NoteTrack 的 objectId 写入noteTrackIdList 并且保存
            self.noteTrackIdList!.addObject(noteTrackModel.objectId, forKey: "list")
            self.noteTrackIdList!.fetchWhenSave = true    //  保存的同时获取新的值
            isSucceed = self.noteTrackIdList!.save()
            if  (isSucceed) {
                //  将新建的 track 加入缓存中
                self.noteTrackModelList.insert(noteTrackModel, atIndex: 0)
            }
            else {
                //  恢复 noteTrackIdList 数据，失败回调
                self.noteTrackIdList!.removeObjectForKey(noteTrackModel.objectId)
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
        track.deleteInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            var isSucceed = succeed
            if isSucceed.boolValue == false { complete?(succeed: false); return }
            //  删除成功后要将 NoteTrack 的 objectId 从 noteTrackIdLis 中删除并保存
            self.noteTrackIdList!.removeObject(track.objectId, forKey: "list")
            self.noteTrackIdList!.fetchWhenSave = true   //  保存的同时获取最新的值
            isSucceed = self.noteTrackIdList!.save()
            if isSucceed {
                //  将要删除的 track 从缓存中删除
                self.noteTrackModelList.removeAtIndex(index)
            }
            else {
                // 恢复 noteTrackIdList 数据，失败回调
                self.noteTrackIdList!.addObject(track.objectId, forKey: "list")
            }
            complete?(succeed: isSucceed)
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
            guard let strongSelf = self else { return }
            if (succeed) {
                strongSelf.noteTrackModelList[index] = noteTrackModel
            }
            complete?(succeed: succeed)
        }
    }
    
    /**
    从缓存中取某条 NoteTrack 对象
    
    - parameter index: 下标号
    - returns: 密码对象
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

protocol CloudCache {
    func generateIdentifier(className: String!) -> String!
}

extension CloudCache {
    func generateIdentifier(className: String!) -> String! {
        return UserInfoManange.shareInstance.uniqueCloudKey! + className
    }
}
  