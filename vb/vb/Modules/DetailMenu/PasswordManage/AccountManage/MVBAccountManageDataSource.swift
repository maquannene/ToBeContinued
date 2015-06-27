//
//  MVBAccountManageDataSource.swift
//  vb
//
//  Created by 马权 on 6/25/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBAccountManageDataSource: NSObject {
    var accountArray: NSMutableArray = NSMutableArray()
    var accountCount: Int = 0
}

extension MVBAccountManageDataSource: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kAccountCell) as! UITableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}