//
//  MVBAccountManageViewController.swift
//  vb
//
//  Created by 马权 on 6/25/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let kAccountCell = "kAccountCell"

class MVBAccountManageViewController: MVBDetailBaseViewController {
    
    var addButton: UIButton!
    var accountListView: UITableView?
    var dataSource: MVBAccountManageDataSource!
    var recordVc: MQMaskController?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        //
        addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
        addButton.frame = CGRectMake(0, 20, 44, 44)
        addButton.addTarget(self, action: Selector("addRecordAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addButton)
        
        //
        dataSource = MVBAccountManageDataSource()
        accountListView = UITableView(frame: CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 64 - 44), style: UITableViewStyle.Plain)
        accountListView!.delegate = self
        accountListView!.dataSource = dataSource as UITableViewDataSource
        accountListView!.rowHeight = 60
        accountListView!.registerClass(MVBAcconutTableViewCell.self, forCellReuseIdentifier: kAccountCell)
        accountListView!.tableFooterView = UIView()
        self.view.addSubview(accountListView!)
    }
    
    func addRecordAction(sender: AnyObject!) -> Void {
        var recordView = NSBundle.mainBundle().loadNibNamed("MVBAccountRecordView", owner: nil, options: nil)[0] as! MVBAccountRecordView
        recordView.frame = CGRectMake(0, 0, self.view.frame.width, 260)
        recordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: recordView, contentCenter: true, delayTime: 0)
        recordVc!.delegate = self
        recordVc!.showWithAnimated(true, completion: nil)
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
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
        println("\(indexPath.row)")
    }
}