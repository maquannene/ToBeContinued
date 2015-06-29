  //
//  MVBPasswordManageDataSource.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
  
typealias MVBPasswordDataOparateCompleteClosure = (succeed: Bool!) -> Void
class MVBPasswordManageDataSource: NSObject {
    
    var passwordIdList: MVBPasswordIdListModel = MVBPasswordIdListModel(identifier: "")
    var passwordDataList: NSMutableArray = NSMutableArray()
    
    override init() {
        super.init()
    }
    
    /**
    请求获每个密码项目objectId的列表
    
    :param: complete 完成回调
    */
    func queryPasswordIdList(complete: MVBPasswordDataOparateCompleteClosure?) {
        var identifier: String = MVBAppDelegate.MVBApp().userID! + NSStringFromClass(self.dynamicType)
        var query: AVQuery = AVQuery(className: "MVBPasswordIdListModel")
        //  根据identifier 识别符查询list
        query.whereKey("identifier", equalTo: identifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            if (objects != nil && objects.count > 0) {
                if let objc = objects[0] as? MVBPasswordIdListModel  {
                    self.passwordIdList = MVBPasswordIdListModel(withoutDataWithObjectId: objc.objectId)
                    self.passwordIdList.fetch()
                    
                    self.passwordIdList.list.enumerateObjectsWithOptions(NSEnumerationOptions.Concurrent, usingBlock: { (objc, index, finish) -> Void in
                        var passwordRecord: MVBPasswordRecordModel = MVBPasswordRecordModel(withoutDataWithObjectId: objc as! String)
                        passwordRecord.fetch()
                        self.passwordDataList.addObject(passwordRecord)
                    })
                    
                    if complete != nil {
                        complete!(succeed: true)
                    }
                }
                else {
                    println("第一次使用，没有密码Id列表，同步创建");
                    self.passwordIdList = MVBPasswordIdListModel(identifier: identifier)
                    self.passwordIdList.save()
                    if complete != nil {
                        complete!(succeed: true)
                    }
                }
            }
            else {
                println("第一次使用，没有密码Id列表，同步创建");
                self.passwordIdList = MVBPasswordIdListModel(identifier: identifier)
                self.passwordIdList.save()
                if complete != nil {
                    complete!(succeed: true)
                }
            }
        }

    }
    
    func addPasswordRecord(recrod: MVBPasswordRecordModel, complete: MVBPasswordDataOparateCompleteClosure?) {
        //  将新的密码记录写入AVOSCloud
        recrod.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error NSError) -> Void in
            //  写完成功后要再将密码记录的objectId写入列表数据并且保存
            self.passwordIdList.addObject(recrod.objectId, forKey: "list")
            self.passwordIdList.fetchWhenSave = true    //  保存的同时获取新的值
            self.passwordIdList.save()
            self.passwordDataList.addObject(recrod)
            if complete != nil {
                complete!(succeed: true)
            }
        }
    }
}

extension MVBPasswordManageDataSource: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordIdList.list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(pwRecordCellId) as? UITableViewCell
        var record: MVBPasswordRecordModel = passwordDataList[indexPath.row] as! MVBPasswordRecordModel
        cell?.textLabel?.text = record.title
        return cell
    }
}