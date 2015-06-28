  //
//  MVBPasswordManageDataSource.swift
//  vb
//
//  Created by 马权 on 6/28/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//
  
typealias MVBPassworDataOparateCompleteClosure = (succeed: Bool!) -> Void
  
class MVBPasswordManageDataSource: NSObject {
    var passwordIdList: MVBPasswordIdListModel = MVBPasswordIdListModel()
    override init() {
        super.init()
    }
    
    func queryPasswordIdList(complete: MVBPassworDataOparateCompleteClosure?) {
        var listIdentifier: String = MVBAppDelegate.MVBApp().userID! + NSStringFromClass(self.dynamicType)
        var query: AVQuery = AVQuery(className: "MVBPasswordIdListModel")
        query.whereKey("listIdentifier", equalTo: listIdentifier)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects: [AnyObject]!, error) -> Void in
            if (objects != nil && objects.count > 0) {
                if let objc = objects[0] as? MVBPasswordIdListModel  {
                    self.passwordIdList = objc
                    if complete != nil {
                        complete!(succeed: true)
                    }
                }
                else {
                    println("第一次使用，没有密码Id列表，同步创建");
                    self.passwordIdList = MVBPasswordIdListModel(listIdentifier: listIdentifier)
                    self.passwordIdList.save()
                    if complete != nil {
                        complete!(succeed: true)
                    }
                }
            }
            else {
                println("第一次使用，没有密码Id列表，同步创建");
                self.passwordIdList = MVBPasswordIdListModel(listIdentifier: listIdentifier)
                self.passwordIdList.save()
                if complete != nil {
                    complete!(succeed: true)
                }
            }
        }

    }
    
    func addPasswordRecord(recrod: MVBPasswordRecordModel, complete: MVBPassworDataOparateCompleteClosure?) {
        recrod.saveInBackgroundWithBlock { [unowned self] (succeed: Bool, error NSError) -> Void in
            self.passwordIdList.addObject(recrod.objectId, forKey: "idList")
            self.passwordIdList.save()
            if complete != nil {
                complete!(succeed: true)
            }
        }
    }
}

extension MVBPasswordManageDataSource: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordIdList.idList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AnyObject? = tableView.dequeueReusableCellWithIdentifier(pwRecordCellId)
        return cell as! UITableViewCell
    }
}