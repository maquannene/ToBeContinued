  //
//  MVBPasswordManageDataSource.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
  
typealias MVBQureyDataCompleteClosure = (succeed: Bool!) -> Void
  
class MVBPasswordManageDataSource: NSObject {
    
    var passwordIdList: MVBPasswordIdListModel?
    lazy var passwordDataList: NSMutableArray = NSMutableArray()                //  存储密码信息列表的缓存数组
    var expandingIndexPath: NSIndexPath?                                        //  展开的cell的IndexPath
    var expandedIndexPath: NSIndexPath?                                         //  被展开（扩展区域）的indexPath
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
}

//  MARK: Public
extension MVBPasswordManageDataSource {
    /**
    请求获取包含每个密码对象objectId的列表（先找到列表，再fetch）
    
    - parameter complete: 完成回调
    */
    func queryPasswordIdList(complete: MVBQureyDataCompleteClosure?) {
        let identifier: String = MVBAppDelegate.MVBApp().uniqueCloudKey! + NSStringFromClass(MVBPasswordIdListModel.self)
        let query: AVQuery = AVQuery(className: MVBPasswordIdListModel.ClassName)
        //  根据identifier 识别符查询list
        query.whereKey(kIdentifier, equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            
            guard error == nil else { complete?(succeed: false); return }
            
            guard objects != nil && objects.count > 0 else { complete?(succeed: false); return }
            
            guard let objc = objects[0] as? MVBPasswordIdListModel else { complete?(succeed: false); return }
            
            self.passwordIdList = objc
            
            complete?(succeed: true)
            
////                        self.passwordIdList = MVBPasswordIdListModel(withoutDataWithObjectId: objc.objectId)
////                        self.passwordIdList!.fetchInBackgroundWithBlock { (object, error) -> Void in
////                            if error != nil {
////                                complete?(succeed: false)
////                            }
////                            else {
////                                complete?(succeed: true)
////                            }
////                        }
        }
    }
    
    /**
    第一次使用 请求创建密码列表对象的id列表
    
    - parameter complete: 完成回调
    */
    func queryCreatePasswordIdList(complete: MVBQureyDataCompleteClosure?) {
        let identifier: String = MVBAppDelegate.MVBApp().uniqueCloudKey! + NSStringFromClass(MVBPasswordIdListModel.self)
        self.passwordIdList = MVBPasswordIdListModel(identifier: identifier)
        self.passwordIdList!.saveInBackgroundWithBlock{ (succeed, error) -> Void in
            complete?(succeed: succeed.boolValue)
        }
    }
    
    /**
    根据passwordIdList的id列表重新生成passwordDataList
    
    - parameter complete: 完成回调
    */
    func queryPasswordDataList(complete: MVBQureyDataCompleteClosure?) {
        let fetchGroup: dispatch_group_t = dispatch_group_create()
        let newPasswordDataList = NSMutableArray()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in self.passwordIdList!.list {
            dispatch_group_enter(fetchGroup)
            let passwordRecord: MVBPasswordRecordModel = MVBPasswordRecordModel(withoutDataWithObjectId: objectId as! String)
            passwordRecord.fetchInBackgroundWithBlock{ (object, error) -> Void in
                if error != nil {
                    success = false
                }
                else {
                    newPasswordDataList.addObject(passwordRecord)
                }
                dispatch_group_leave(fetchGroup)
            }
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), { () -> Void in
            if success == true {
                //  对数据根据时间进行排序
                newPasswordDataList.sortUsingComparator {
                    return ($0 as! MVBPasswordRecordModel).createdAt.compare(($1 as! MVBPasswordRecordModel).createdAt)
                }
            }
            self.passwordDataList = newPasswordDataList
            complete?(succeed: success)
        })
    }
    
    /**
    请求新增密码对象
    
    - parameter recrod:   密码项的类对象
    - parameter complete: 完成回调
    */
    func queryAddPasswordRecord(record: MVBPasswordRecordModel, complete: MVBQureyDataCompleteClosure?) {
        //  将新的密码记录写入AVOSCloud
        record.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            if succeed.boolValue == false { complete?(succeed: false); return }
            //  写完成功后要再将密码记录的objectId写入passwordIdList并且保存
            self.passwordIdList!.addObject(record.objectId, forKey: "list")
            self.passwordIdList!.fetchWhenSave = true    //  保存的同时获取新的值
            self.passwordIdList!.save()
            //  将新建的record加入缓存中
            self.passwordDataList.addObject(record)
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求删除密码对象
    
    - parameter index:    要删除的index
    - parameter complete: 删除完成回调
    */
    func queryDeletePasswordRecord(index: Int!, complete: MVBQureyDataCompleteClosure?) {
        let record: MVBPasswordRecordModel! = fetchPasswordRecord(index)
        record.deleteInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            if succeed.boolValue == false { complete?(succeed: false); return }
            //  删除成功后要将密码记录的objectId从passwordIdLis中删除并保存
            self.passwordIdList!.removeObject(record.objectId, forKey: "list")
            self.passwordIdList!.fetchWhenSave = true   //  保存的同时获取最新的值
            self.passwordIdList!.save()
            //  将要删除的record从缓存中删除
            self.passwordDataList.removeObjectAtIndex(index)
            complete?(succeed: succeed)
        }
    }
    
    /**
    请求更新密码对象
    
    - parameter record:   需要更新的密码对象
    - parameter complete: 完成回调
    */
    func queryUpdatePasswordRecord(record: MVBPasswordRecordModel, complete: MVBQureyDataCompleteClosure?) {
        record.saveInBackgroundWithBlock { (succeed: Bool, error: NSError!) -> Void in
            (complete?(succeed: succeed))!
        }
    }
    
    /**
    从缓存中取某条密码对象
    
    - parameter index: 下标号
    - returns: 密码对象
    */
    func fetchPasswordRecord(index: Int!) -> MVBPasswordRecordModel! {
        return passwordDataList[index] as? MVBPasswordRecordModel
    }

    func convertToActualIndexPath(indexPath: NSIndexPath) -> NSIndexPath! {
        if (expandedIndexPath != nil && indexPath.row >= expandedIndexPath!.row) {
            return NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        }
        return indexPath
    }
}
  