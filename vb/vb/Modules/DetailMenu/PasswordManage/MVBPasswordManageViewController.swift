//
//  MVBPasswordManageViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SLExpandableTableView

let pwRecordCellId = "passwordRecordCell"
let pwRecordDetailCellId = "passwordRecordDetailCell"

class MVBPasswordManageViewController: MVBDetailBaseViewController {
    
    weak var newPasswordBtn: UIButton?
    weak var newPasswordConfigVc: MVBNewPasswordConfigViewController?
    var passwordListTableView: SLExpandableTableView?
    
    var passwordCount: Int = 0
    var expendIndex: Int = -1
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        newPasswordBtn = (UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton)
        newPasswordBtn!.addTarget(self, action: "addNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newPasswordBtn!)
        
        passwordListTableView = SLExpandableTableView(frame: CGRectMake(20, 64, 280, 400), style: UITableViewStyle.Plain)
        passwordListTableView!.tableFooterView = UIView(frame: CGRectZero)
        passwordListTableView!.tableHeaderView = UIView(frame: CGRectZero)
        passwordListTableView!.rowHeight = 44
        passwordListTableView!.delegate = self
        passwordListTableView!.dataSource = self
//        passwordListTableView!.backgroundColor = UIColor.brownColor()
        passwordListTableView!.registerClass(MVBPasswordRecordCell.self, forCellReuseIdentifier: pwRecordCellId)
        passwordListTableView!.registerClass(MVBPasswordRecordDetailCell.self, forCellReuseIdentifier: pwRecordDetailCellId)
        self.view.addSubview(passwordListTableView!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    
    func addNewPasswrodAction(sender: AnyObject!) {
//        self .performSegueWithIdentifier("newPasswordConfigVc", sender: sender)
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

extension MVBPasswordManageViewController: SLExpandableTableViewDelegate, SLExpandableTableViewDatasource {
    
    //  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        else {
            return 44
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var passwordRecordCell:MVBPasswordRecordDetailCell = tableView.dequeueReusableCellWithIdentifier(pwRecordDetailCellId) as! MVBPasswordRecordDetailCell
        passwordRecordCell.selectionStyle = UITableViewCellSelectionStyle.None
        passwordRecordCell.textLabel?.text = "\(indexPath.row)"
        return passwordRecordCell
    }
    
    func tableView(tableView: SLExpandableTableView!, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func tableView(tableView: SLExpandableTableView!, needsToDownloadDataForExpandableSection section: Int) -> Bool {
        return !(section == expendIndex)
    }
    
    func tableView(tableView: SLExpandableTableView!, expandingCellForSection section: Int) -> UITableViewCell! {
        var passwordRecordCell:MVBPasswordRecordCell = tableView.dequeueReusableCellWithIdentifier(pwRecordCellId) as! MVBPasswordRecordCell
        passwordRecordCell.selectionStyle = UITableViewCellSelectionStyle.None
        passwordRecordCell.textLabel?.text = "\(section)"
        return passwordRecordCell
    }
    
    //  UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: SLExpandableTableView!, downloadDataForExpandableSection section: Int) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.expendIndex = section
            tableView.expandSection(section, animated: false)
        }
    }
}
