//
//  MVBPasswordManageViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let pwRecordCellId = "passwordRecordCell"
let pwRecordDetailCellId = "passwordRecordDetailCell"

class MVBPasswordManageViewController: MVBDetailBaseViewController {
    
    var newPasswordBtn: UIButton?
    
    var dataSource: MVBPasswordManageDataSource?
    var passwordListTableView: UITableView?

    var newPasswordVc: MQMaskController?
  
    var selectedIndex: Int = -1
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        //  基础设置
        view.backgroundColor = UIColor.greenColor()
        newPasswordBtn = (UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton)
        newPasswordBtn!.frame = CGRectMake(0, 0, 44, 44)
        newPasswordBtn!.addTarget(self, action: "addNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(newPasswordBtn!)
        
        dataSource = MVBPasswordManageDataSource()
        dataSource!.tableViewCellDelegate = self
        
        passwordListTableView = UITableView(frame: CGRectMake(20, 64, 280, 400), style: UITableViewStyle.Plain)
        passwordListTableView!.tableFooterView = UIView(frame: CGRectZero)
        passwordListTableView!.tableHeaderView = UIView(frame: CGRectZero)
        passwordListTableView!.rowHeight = 44
        passwordListTableView!.delegate = self
        passwordListTableView!.dataSource = dataSource
        passwordListTableView!.registerClass(MVBPasswordRecordCell.self, forCellReuseIdentifier: pwRecordCellId)
        view.addSubview(passwordListTableView!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (dataSource!.passwordIdList != nil) {
            return
        }
        
        SVProgressHUD.showWithStatus("加载列表")
        dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
            if succeed == true {
                self.dataSource?.queryPasswordDataList({ (succeed) -> Void in
                    SVProgressHUD.dismiss()
                    if succeed == true {
                        self.passwordListTableView!.reloadData()
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus("加载失败")
                    }
                })
            }
            else {
                self.dataSource!.queryCreatePasswordIdList({ (succeed) -> Void in
                    SVProgressHUD.dismiss()
                    if succeed == true {
                        
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus("加载失败")
                    }
                })
            }
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

extension MVBPasswordManageViewController {
    func addNewPasswrodAction(sender: AnyObject!) {
        var newPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
        newPasswordView.frame = CGRectMake(0, 0, self.view.frame.width, 260)
        newPasswordView.createButton.addTarget(self, action: "confirmCreateNewPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newPasswordView, contentCenter: true, delayTime: 0)
        newPasswordVc!.showWithAnimated(true, completion: nil)
    }
    
    func confirmCreateNewPasswordAction(sender: AnyObject!) {
        var contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        dataSource!.queryAddPasswordRecord( MVBPasswordRecordModel(title: contentView.titleTextField.text, detailContent: contentView.detailContentTextField.text), complete: { [unowned self]  (succeed) -> Void in
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
                
            })
        })
    }
    
    func confirmUpdataPasswordAction(sender: AnyObject!) {
        var contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        var recordModel: MVBPasswordRecordModel = dataSource!.fetchPassrecordRecord(selectedIndex)
        recordModel.update(title: contentView.titleTextField.text, detailContent: contentView.detailContentTextField.text)
        dataSource!.queryUpdatePasswordRecord(recordModel, complete: { [unowned self] (succeed) -> Void in
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
            })
        })
    }
}

extension MVBPasswordManageViewController: UITableViewDelegate {
    //  UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell! = tableView.cellForRowAtIndexPath(indexPath)
        if tableView.editing == false {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        selectedIndex = indexPath.row
        var recordModel: MVBPasswordRecordModel = dataSource!.fetchPassrecordRecord(selectedIndex)
        var detailPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
        detailPasswordView.configureData(recordModel.title, detailContent: recordModel.detailContent)
        detailPasswordView.frame = CGRectMake(0, 0, self.view.frame.width, 260)
        detailPasswordView.createButton.addTarget(self, action: "confirmUpdataPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: detailPasswordView, contentCenter: true, delayTime: 0)
        newPasswordVc!.showWithAnimated(true, completion: nil)
    }
}

extension MVBPasswordManageViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        println("删除按键")
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {

    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, scrollingToState state: SWCellState) {
        if let recordCell = cell as? MVBPasswordRecordCell {
            if state == SWCellState.CellStateRight {
                self.mm_drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
            }
            if state == SWCellState.CellStateCenter {
                self.mm_drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.All
            }
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        return true
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
}
