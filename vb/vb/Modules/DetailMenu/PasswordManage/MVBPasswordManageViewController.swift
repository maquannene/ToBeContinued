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
    
    var newPasswordBtn: UIButton?
    
    var dataSource: MVBPasswordManageDataSource?
    var passwordListTableView: UITableView?
    
    var newPasswordVc: MQMaskController?
    
    weak var newPasswordConfigVc: MVBNewPasswordConfigViewController?
    
    override func loadView() {
        super.loadView()
//        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {

        //  基础设置
        self.view.backgroundColor = UIColor.greenColor()
        newPasswordBtn = (UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton)
        newPasswordBtn!.frame = CGRectMake(0, 0, 44, 44)
        newPasswordBtn!.addTarget(self, action: "addNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(newPasswordBtn!)
        
        dataSource = MVBPasswordManageDataSource()
        dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
            self.passwordListTableView!.reloadData()
        }
        
        passwordListTableView = UITableView(frame: CGRectMake(20, 64, 280, 400), style: UITableViewStyle.Plain)
        passwordListTableView!.tableFooterView = UIView(frame: CGRectZero)
        passwordListTableView!.tableHeaderView = UIView(frame: CGRectZero)
        passwordListTableView!.rowHeight = 44
        passwordListTableView!.delegate = self
        passwordListTableView!.dataSource = dataSource
        passwordListTableView!.registerClass(MVBPasswordRecordCell.self, forCellReuseIdentifier: pwRecordCellId)
        self.view.addSubview(passwordListTableView!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier as String? {
            self.setValue(segue.destinationViewController, forKey: identifier)
        }
    }
    
    func addNewPasswrodAction(sender: AnyObject!) {
        var newPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
        newPasswordView.frame = CGRectMake(0, 0, self.view.frame.width, 260)
        newPasswordView.createButton.addTarget(self, action: "finishCreateNewPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newPasswordView, contentCenter: true, delayTime: 0)
        newPasswordVc!.showWithAnimated(true, completion: nil)
    }
    
    func finishCreateNewPasswordAction(sender: AnyObject!) {
        var contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        dataSource!.addPasswordRecord( MVBPasswordRecordModel(title: contentView.titleTextField.text, detailContent: contentView.detailContentTextField.text), complete: { [unowned self]  (succeed) -> Void in
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
                
            })
        })
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

extension MVBPasswordManageViewController: UITableViewDelegate {
    //  UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
