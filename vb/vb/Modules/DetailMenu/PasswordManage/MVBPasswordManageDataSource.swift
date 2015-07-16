  //
//  MVBPasswordManageDataSource.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
  
typealias MVBPasswordDataOparateCompleteClosure = (succeed: Bool!) -> Void
  
class MVBPasswordManageDataSource: NSObject {
    var passwordIdList: MVBPasswordIdListModel?
    var passwordDataList: NSMutableArray = NSMutableArray()             //  存储密码信息列表的缓存数组
    var expandingIndexPath: NSIndexPath?
    var expandedIndexPath: NSIndexPath?
    weak var tableViewCellDelegate: SWTableViewCellDelegate?
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

// MARK: Public
extension MVBPasswordManageDataSource {
    /**
    请求获取包含每个密码对象objectId的列表（先找到列表，再fetch）
    
    :param: complete 完成回调
    */
    func queryPasswordIdList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var identifier: String = MVBAppDelegate.MVBApp().userID! + NSStringFromClass(MVBPasswordIdListModel.self)
        var query: AVQuery = AVQuery(className: "MVBPasswordIdListModel")
        //  根据identifier 识别符查询list
        query.whereKey("identifier", equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            if error != nil {
                complete?(succeed: false)
            }
            else {
                if (objects != nil && objects.count > 0) {
                    if let objc = objects[0] as? MVBPasswordIdListModel  {
                        //  取passwordIdList
                        self.passwordIdList = MVBPasswordIdListModel(withoutDataWithObjectId: objc.objectId)
                        self.passwordIdList!.fetchInBackgroundWithBlock({ [unowned self] (object, error) -> Void in
                            if error != nil {
                                complete?(succeed: false)
                            }
                            else {
                                complete?(succeed: true)
                            }
                        })
                    }
                    else {
                        complete?(succeed: false)
                    }
                }
                else {
                    complete?(succeed: false)
                }
            }
        }
    }
    
    /**
    第一次使用 请求创建密码列类对象的id列表
    
    :param: complete 完成回调
    */
    func queryCreatePasswordIdList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var identifier: String = MVBAppDelegate.MVBApp().userID! + NSStringFromClass(MVBPasswordIdListModel.self)
        self.passwordIdList = MVBPasswordIdListModel(identifier: identifier)
        self.passwordIdList!.saveInBackgroundWithBlock({ (succeed, error) -> Void in
            complete?(succeed: succeed)
        })
    }
    
    /**
    根据passwordIdList的id列表重新生成passwordDataList
    
    :param: complete 完成回调
    */
    func queryPasswordDataList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var fetchGroup: dispatch_group_t = dispatch_group_create()
        self.passwordDataList.removeAllObjects()
        var success = true      //  加载标志位，一旦有一个失败，就标记失败
        for objectId in self.passwordIdList!.list {
            dispatch_group_enter(fetchGroup)
            var passwordRecord: MVBPasswordRecordModel = MVBPasswordRecordModel(withoutDataWithObjectId: objectId as! String)
            passwordRecord.fetchInBackgroundWithBlock({ [unowned self] (object, error) -> Void in
                if error != nil {
                    success = false
                }
                else {
                    self.passwordDataList.addObject(passwordRecord)
                }
                dispatch_group_leave(fetchGroup)
            })
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), { () -> Void in
            if success == true {
                //  对数据根据时间进行排序
                self.passwordDataList.sortUsingComparator({ (objc1, ojbc2) -> NSComparisonResult in
                    return (objc1 as! MVBPasswordRecordModel).createdAt.compare((ojbc2 as! MVBPasswordRecordModel).createdAt)
                })
            }
            complete?(succeed: success)
        })
    }
    
    /**
    请求新增密码对象
    
    :param: recrod   密码项的类对象
    :param: complete 完成回调
    */
    func queryAddPasswordRecord(record: MVBPasswordRecordModel, complete: MVBPasswordDataOparateCompleteClosure?) {
        //  将新的密码记录写入AVOSCloud
        record.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            if succeed == false { complete?(succeed: false); return }
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
    
    :param: index    要删除的index
    :param: complete 删除完成回调
    */
    func queryDeletePasswordRecord(index: Int!, complete: MVBPasswordDataOparateCompleteClosure?) {
        var record: MVBPasswordRecordModel! = fetchPasswordRecord(index)
        record.deleteInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            if succeed == false { complete?(succeed: false); return }
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
    
    :param: record   需要更新的密码对象
    :param: complete 完成回调
    */
    func queryUpdatePasswordRecord(record: MVBPasswordRecordModel, complete: MVBPasswordDataOparateCompleteClosure?) {
        record.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error: NSError!) -> Void in
            complete?(succeed: succeed)
        }
    }
    
    /**
    从缓存中取某条密码对象
    
    :param: index 下标号
    :returns: 密码对象
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
  
// MARK: UITableViewDataSource
extension MVBPasswordManageDataSource: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedIndexPath != nil {
            return passwordDataList.count + 1
        }
        else {
            return passwordDataList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var actualIndexPath = convertToActualIndexPath(indexPath)
        var record: MVBPasswordRecordModel = passwordDataList[actualIndexPath.row] as! MVBPasswordRecordModel
        //  如果是展开的detailCell
        if (expandedIndexPath != nil && expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            var detailCell: MVBPasswordRecordDetailCell = tableView.dequeueReusableCellWithIdentifier(pwRecordDetailCellId) as! MVBPasswordRecordDetailCell
            detailCell.configureWithRecord(record)
            return detailCell
        }
        else {
            var titleCell: MVBPasswordRecordCell = tableView.dequeueReusableCellWithIdentifier(pwRecordCellId) as! MVBPasswordRecordCell
            titleCell.indexPath = actualIndexPath
            titleCell.delegate = tableViewCellDelegate
            titleCell.configureWithRecord(record)
            return titleCell
        }
    }
}

  