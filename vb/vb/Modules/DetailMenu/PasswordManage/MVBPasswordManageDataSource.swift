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
    var passwordDataList: NSMutableArray = NSMutableArray()
    weak var tableViewCellDelegate: SWTableViewCellDelegate?
    
    /**
    请求获取包含每个密码对象objectId的列表
    
    :param: complete 完成回调
    */
    func queryPasswordIdList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var identifier: String = MVBAppDelegate.MVBApp().userID! + NSStringFromClass(MVBPasswordIdListModel.self)
        var query: AVQuery = AVQuery(className: "MVBPasswordIdListModel")
        //  根据identifier 识别符查询list
        query.whereKey("identifier", equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            if complete != nil {
                if error != nil {
                    complete!(succeed: false)
                }
                else {
                    if (objects != nil && objects.count > 0) {
                        if let objc = objects[0] as? MVBPasswordIdListModel  {
                            //  取passwordIdList
                            self.passwordIdList = MVBPasswordIdListModel(withoutDataWithObjectId: objc.objectId)
                            self.passwordIdList!.fetchInBackgroundWithBlock({ [unowned self] (object, error) -> Void in
                                
                                if complete != nil {
                                    if error != nil {
                                        complete!(succeed: false)
                                    }
                                    else {
                                        complete!(succeed: true)
                                    }
                                }
                            })
                        }
                        else {
                            complete!(succeed: false)
                        }
                    }
                    else {
                        complete!(succeed: false)
                    }
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
            if complete != nil {
                if error != nil {
                    complete!(succeed: false)
                }
                else {
                    complete!(succeed: true)
                }
            }
        })
    }
    
    /**
    请求新增密码对象
    
    :param: recrod   密码项的类对象
    :param: complete 完成回调
    */
    func queryAddPasswordRecord(recrod: MVBPasswordRecordModel, complete: MVBPasswordDataOparateCompleteClosure?) {
        //  将新的密码记录写入AVOSCloud
        recrod.setObject(self.passwordIdList!.list.count, forKey: "index")
        recrod.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error NSError) -> Void in
            //  写完成功后要再将密码记录的objectId写入passwordIdList并且保存
            self.passwordIdList!.addObject(recrod.objectId, forKey: "list")
            self.passwordIdList!.fetchWhenSave = true    //  保存的同时获取新的值
            self.passwordIdList!.save()
            //  将新建的record加入内存中
            self.passwordDataList.addObject(recrod)
            if complete != nil {
                complete!(succeed: true)
            }
        }
    }
    
    /**
    从缓存中取某条密码对象
    
    :param: index 下标号
    
    :returns: 密码对象
    */
    func fetchPassrecordRecord(index: Int!) -> MVBPasswordRecordModel! {
        return passwordDataList[index] as? MVBPasswordRecordModel
    }
    
    /**
    请求更新密码对象
    
    :param: record   需要更新的密码对象
    :param: complete 完成回调
    */
    func queryUpdatePasswordRecord(record: MVBPasswordRecordModel, complete: MVBPasswordDataOparateCompleteClosure?) {
        record.saveInBackgroundWithBlock { [unowned self] (succeed, error) -> Void in
            if complete != nil {
                complete!(succeed: succeed)
            }
        }
    }
    
    /**
    根据passwordIdList的id列表重新生成passwordDataList
    
    :param: complete 完成回调
    */
    func queryPasswordDataList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var fetchGroup: dispatch_group_t = dispatch_group_create()
        self.passwordDataList.removeAllObjects()
        for objectId in self.passwordIdList!.list {
            dispatch_group_enter(fetchGroup)
            var passwordRecord: MVBPasswordRecordModel = MVBPasswordRecordModel(withoutDataWithObjectId: objectId as! String)
            passwordRecord.fetchInBackgroundWithBlock({ [unowned self] (object, error) -> Void in
                self.passwordDataList.addObject(passwordRecord)
                dispatch_group_leave(fetchGroup)
            })
        }
        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), { () -> Void in
            //  对数据根据时间进行排序
            self.passwordDataList.sortUsingComparator({ (objc1, ojbc2) -> NSComparisonResult in
                return (objc1 as! MVBPasswordRecordModel).createdAt.compare((ojbc2 as! MVBPasswordRecordModel).createdAt)
            })
            
            if complete != nil {
                complete!(succeed: true)
            }
        })
    }
}

extension MVBPasswordManageDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordDataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MVBPasswordRecordCell! = tableView.dequeueReusableCellWithIdentifier(pwRecordCellId) as! MVBPasswordRecordCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = tableViewCellDelegate
        cell.rightUtilityButtons = rightButtons() as [AnyObject]
        var record: MVBPasswordRecordModel = passwordDataList[indexPath.row] as! MVBPasswordRecordModel
        cell?.textLabel?.text = record.title
        return cell
    }
}

extension MVBPasswordManageDataSource {
    func rightButtons() -> NSArray {
        var rightButtons: NSMutableArray = NSMutableArray()
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
        return rightButtons
    }
}
  