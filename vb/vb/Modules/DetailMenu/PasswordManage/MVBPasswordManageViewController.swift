//
//  MVBPasswordManageViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

let pwRecordCellId = "passwordRecordCell"
let pwRecordDetailCellId = "passwordRecordDetailCell"

//  MARK: LeftCycle
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
        
        configurePullToRefresh()
        
        passwordListTableView!.pullToRefreshView.refreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (netWorkState: AFNetworkReachabilityStatus) -> Void in
            switch netWorkState {
            case AFNetworkReachabilityStatus.NotReachable:
                println("网络不可用")
                SVProgressHUD.showInfoWithStatus("网络不可用", maskType: SVProgressHUDMaskType.Black)
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
                println("3G")
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                println("wifi")
            default:
                println("未知状态")
            }
        }
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

//  MARK: Private
extension MVBPasswordManageViewController {
    func reloadData() {
        if (dataSource!.passwordIdList != nil) {
            return
        }
        
        SVProgressHUD.showWithStatus("加载列表")
        dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
            if succeed == true {
                self.dataSource?.queryPasswordDataList({ [unowned self] (succeed) -> Void in
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
                self.dataSource!.queryCreatePasswordIdList({ [unowned self] (succeed) -> Void in
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
    
    func configurePullToRefresh() {
        passwordListTableView!.showPullToRefreshView = true
        
        var textArray: NSArray = ["下拉刷新", "松手刷新", "正在刷新", "刷新成功", "刷新失败"]
        
        textArray.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
            var tipsLabel = UILabel(frame: CGRectMake(0, 10, 200, 40))
            tipsLabel.textAlignment = NSTextAlignment.Center
            tipsLabel.backgroundColor = UIColor.whiteColor()
            tipsLabel.text = textArray[idx] as? String
            self.passwordListTableView!.pullToRefreshView.customRefreshView(tipsLabel, forState: MQPullToRefreshState(rawValue: idx)!)
        }
        
        passwordListTableView!.addActionHandlerOnPullToRefreshView(MQPullToRefreshType.Top, triggerDistance: 60) { [unowned self] () -> Void in
            self.dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
                if succeed == true {
                    self.dataSource?.queryPasswordDataList({ [unowned self] (succeed) -> Void in
                        if succeed == true {
                            self.passwordListTableView!.reloadData()
                            self.passwordListTableView!.pullToRefreshView.refreshSucceed(true, duration: 0.5)
                        }
                        else {
                            self.passwordListTableView!.pullToRefreshView.refreshSucceed(false, duration: 0.5)
                        }
                    })
                }
                else {
                    self.dataSource!.queryCreatePasswordIdList({ [unowned self] (succeed) -> Void in
                        if succeed == true {
                            self.passwordListTableView!.pullToRefreshView.refreshDone()
                        }
                        else {
                            self.passwordListTableView!.pullToRefreshView.refreshSucceed(false, duration: 0.5)
                        }
                    })
                }
            }
        }
    }
}

//  MARK: Action
extension MVBPasswordManageViewController {
    /**
    新增密码条目
    */
    func addNewPasswrodAction(sender: AnyObject!) {
        var newPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
        newPasswordView.frame = CGRectMake(0, -260, self.view.frame.width, 260)
        newPasswordView.createButton.addTarget(self, action: "confirmCreateNewPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newPasswordView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newPasswordVc!.maskView.backgroundColor = UIColor.clearColor()
        newPasswordVc!.delegate = self
        //  设置显示动画
        newPasswordVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(newPasswordView.frame, 0, 260)
            self.newPasswordVc!.maskView.backgroundColor = RGBA(0, 0, 0, 0.3)
        }
        //  显示关闭动画
        newPasswordVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(newPasswordView.frame, 0, -260)
             self.newPasswordVc!.maskView.backgroundColor = RGBA(0, 0, 0, 0)
        }
        newPasswordVc!.showWithAnimated(true, completion: nil)
        newPasswordView.titleTextView.becomeFirstResponder()
    }
    
    /**
    确认新增密码条目事件
    */
    func confirmCreateNewPasswordAction(sender: AnyObject!) {
        var contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        dataSource!.queryAddPasswordRecord( MVBPasswordRecordModel(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text), complete: { [unowned self]  (succeed) -> Void in
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
            })
        })
    }
    
    /**
    确认更新密码条目事件
    */
    func confirmUpdataPasswordAction(sender: AnyObject!) {
        var contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        var recordModel: MVBPasswordRecordModel = dataSource!.fetchPassrecordRecord(selectedIndex)
        recordModel.update(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
        dataSource!.queryUpdatePasswordRecord(recordModel, complete: { [unowned self] (succeed) -> Void in
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
            })
        })
    }
}

//  MARK: UITableViewDelegate
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
        detailPasswordView.frame = CGRectMake(0, -260, self.view.frame.width, 260)
        detailPasswordView.createButton.addTarget(self, action: "confirmUpdataPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: detailPasswordView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newPasswordVc!.delegate = self
        newPasswordVc!.maskView.backgroundColor = UIColor.clearColor()
        //  设置显示动画
        newPasswordVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(detailPasswordView.frame, 0, 260)
            self.newPasswordVc!.maskView.backgroundColor = RGBA(0, 0, 0, 0.3)
        }
        //  显示关闭动画
        newPasswordVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(detailPasswordView.frame, 0, -260)
            self.newPasswordVc!.maskView.backgroundColor = RGBA(0, 0, 0, 0)
        }
        newPasswordVc!.showWithAnimated(true, completion: nil)
        detailPasswordView.titleTextView.becomeFirstResponder()
    }
}

//  MARK: SWTableViewCellDelegate
extension MVBPasswordManageViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if let recordCell = cell as? MVBPasswordRecordCell {
            dataSource!.queryDeletePasswordRecord(recordCell.indexPath.row, complete: { [unowned self] (succeed) -> Void in
                self.passwordListTableView!.deleteRowsAtIndexPaths([recordCell.indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            })
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {

    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, scrollingToState state: SWCellState) {
        if let recordCell = cell as? MVBPasswordRecordCell {
            if state == SWCellState.CellStateRight {

            }
            if state == SWCellState.CellStateCenter {
                
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

// MARK: MQMaskControllerDelegate
extension MVBPasswordManageViewController: MQMaskControllerDelegate {
    func maskControllerWillDismiss(maskController: MQMaskController!) {
        if let contentView = maskController.contentView as? MVBNewPasswordView {
            if contentView.titleTextView.isFirstResponder() {
                contentView.titleTextView.resignFirstResponder()
            }
            if contentView.detailContentTextView.isFirstResponder() {
                contentView.detailContentTextView.resignFirstResponder()
            }
        }
    }
}
