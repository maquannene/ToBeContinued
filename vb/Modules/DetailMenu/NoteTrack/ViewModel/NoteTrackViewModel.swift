//
//  NoteTrackViewModel.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
 
import AVOSCloud
  
typealias QureyDataCompleteClosure = (succeed: Bool!) -> Void
  
class NoteTrackViewModel: NSObject {
    
    var noteTrackIdList: NoteTrackIdListModel?
    lazy var noteTrackModelList: NSMutableArray = NSMutableArray()              //  存储密码信息列表的缓存数组
    var expandingIndexPath: NSIndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: NSIndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }
    
}

//  MARK: Public
extension NoteTrackViewModel {
    /**
    请求查找包含每个密码对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryFindNoteTrackIdListCompletion(complete: QureyDataCompleteClosure?)
    {
        let identifier: String = UserInfoManange.shareInstance.uniqueCloudKey! + NSStringFromClass(NoteTrackIdListModel.self)
        let query: AVQuery = AVQuery(className: NoteTrackIdListModel.ClassName)
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
    第一次使用 请求创建密码列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreateNoteTrackIdListCompletion(complete: QureyDataCompleteClosure?)
    {
        let identifier: String = UserInfoManange.shareInstance.uniqueCloudKey! + NSStringFromClass(NoteTrackIdListModel.self)
        self.noteTrackIdList = NoteTrackIdListModel(identifier: identifier)
        self.noteTrackIdList!.saveInBackgroundWithBlock{ (succeed, error) -> Void in
            complete?(succeed: succeed.boolValue)
        }
    }
    
    /**
    根据noteTrackIdList的id列表重新生成noteTrackModelList
    
    - parameter complete: 完成回调
    */
    func queryNoteTrackListCompletion(complete: QureyDataCompleteClosure?)
    {
        let fetchGroup: dispatch_group_t = dispatch_group_create()
        let newNoteTrackModelList = NSMutableArray()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in self.noteTrackIdList!.list {
            dispatch_group_enter(fetchGroup)
            let noteTrackModel: NoteTrackModel = NoteTrackModel(outDataWithObjectId: objectId as! String)
            noteTrackModel.fetchInBackgroundWithBlock{ (object, error) -> Void in
                if error != nil {
                    success = false
                }
                else {
                    newNoteTrackModelList.addObject(noteTrackModel)
                }
                dispatch_group_leave(fetchGroup)
            }
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), { () -> Void in
            if success == true {
                //  对数据根据时间进行排序
                newNoteTrackModelList.sortUsingComparator {
                    return ($1 as! NoteTrackModel).createdAt.compare(($0 as! NoteTrackModel).createdAt)
                }
            }
            self.noteTrackModelList = newNoteTrackModelList
            complete?(succeed: success)
        })
    }
    
    /**
    请求新增密码对象
    
    - parameter recrod:   密码项的类对象
    - parameter complete: 完成回调
    */
    func queryAddNoteTrack(noteTrackModel: NoteTrackModel, complete: QureyDataCompleteClosure?)
    {
        //  将新的密码记录写入AVOSCloud
        noteTrackModel.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            guard succeed.boolValue == true else { complete?(succeed: false); return }
            //  写完成功后要再将密码记录的objectId写入noteTrackIdList并且保存
            self.noteTrackIdList!.addObject(noteTrackModel.objectId, forKey: "list")
            self.noteTrackIdList!.fetchWhenSave = true    //  保存的同时获取新的值
            self.noteTrackIdList!.save()
            //  将新建的track加入缓存中
            self.noteTrackModelList.insertObject(noteTrackModel, atIndex: 0)
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求删除密码对象
    
    - parameter index:    要删除的index
    - parameter complete: 删除完成回调
    */
    func queryDeleteNoteTrackAtIndex(index: Int!, complete: QureyDataCompleteClosure?)
    {
        let track: NoteTrackModel! = fetchNoteTrackModel(index)
        track.deleteInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            if succeed.boolValue == false { complete?(succeed: false); return }
            //  删除成功后要将密码记录的objectId从noteTrackIdLis中删除并保存
            self.noteTrackIdList!.removeObject(track.objectId, forKey: "list")
            self.noteTrackIdList!.fetchWhenSave = true   //  保存的同时获取最新的值
            self.noteTrackIdList!.save()
            //  将要删除的track从缓存中删除
            self.noteTrackModelList.removeObjectAtIndex(index)
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求更新密码对象
    
    - parameter track:   需要更新的密码对象
    - parameter complete: 完成回调
    */
    func queryUpdateNoteTrack(noteTrackModel: NoteTrackModel, complete: QureyDataCompleteClosure?)
    {
        noteTrackModel.saveInBackgroundWithBlock { (succeed: Bool, error: NSError!) -> Void in
            (complete?(succeed: succeed))!
        }
    }
    
    /**
    从缓存中取某条密码对象
    
    - parameter index: 下标号
    - returns: 密码对象
    */
    func fetchNoteTrackModel(index: Int!) -> NoteTrackModel!
    {
        return noteTrackModelList[index] as? NoteTrackModel
    }

    func convertToActualIndexPath(indexPath: NSIndexPath) -> NSIndexPath!
    {
        if (expandedIndexPath != nil && indexPath.row >= expandedIndexPath!.row) {
            return NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        }
        return indexPath
    }
}
  