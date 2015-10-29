//
//  MVBAccountManageViewController.swift
//  vb
//
//  Created by 马权 on 6/25/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import MQMaskController

let kAccountCell = "kAccountCell"

class MVBAccountManageViewController: MVBDetailBaseViewController {
    
    var addButton: UIButton!
    var accountListView: UITableView?
    lazy var dataSource: MVBAccountManageDataSource = MVBAccountManageDataSource()
    var recordVc: MQMaskController?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        //
        addButton = UIButton(type: UIButtonType.ContactAdd)
        addButton.frame = CGRectMake(0, 20, 44, 44)
        addButton.addTarget(self, action: Selector("addRecordAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addButton)
        
        //
        accountListView = UITableView(frame: CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 64 - 44), style: UITableViewStyle.Plain)
        accountListView!.delegate = self
        accountListView!.dataSource = dataSource as UITableViewDataSource
        accountListView!.rowHeight = 60
        accountListView!.registerClass(MVBAcconutTableViewCell.self, forCellReuseIdentifier: kAccountCell)
        accountListView!.tableFooterView = UIView()
        self.view.addSubview(accountListView!)
    }
    
    @objc private func addRecordAction(sender: AnyObject!) -> Void {
        let recordView = NSBundle.mainBundle().loadNibNamed("MVBAccountRecordView", owner: nil, options: nil)[0] as! MVBAccountRecordView
        recordView.frame = CGRectMake(0, 0, self.view.frame.width, 260)
        recordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: recordView, contentCenter: true, delayTime: 0)
        recordVc!.delegate = self
        recordVc!.showWithAnimated(true, completion: nil)
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n")
    }

}

extension MVBAccountManageViewController: MQMaskControllerDelegate {
    func maskControllerWillDismiss(maskController: MQMaskController!) {
        
    }
    
    func maskControllerDidDismiss(maskController: MQMaskController!) {
        recordVc = nil
    }
}

extension MVBAccountManageViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row)")
    }
}