//
//  MVBPasswordManageViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

//  MARK: LeftCycle
class MVBPasswordManageViewController: MVBDetailBaseViewController {
    
    struct Static {
        static let pwRecordCellId = "passwordRecordCell"
        static let pwRecordDetailCellId = "passwordRecordDetailCell"
    }

    var newPasswordBtn: UIButton?
    
    var dataSource: MVBPasswordManageDataSource?
    var passwordListTableView: UITableView?

    var newPasswordVc: MQMaskController?
    var operateCellIndex: Int = -1
    
    convenience init(type: MVBDetailBaseViewControllerCustomType) {
        self.init()
        if type == MVBDetailBaseViewControllerCustomType.withNavi {
            let navi: UINavigationController = UINavigationController(rootViewController: self)
            mainNavi = navi
        }
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        
        //  全屏的回滑手势
//        self.fd_interactivePopDisabled = true
//        self.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = getScreenSize().width
        //  基础设置
        view.backgroundColor = UIColor.greenColor()
        newPasswordBtn = UIButton(type: UIButtonType.ContactAdd)
        newPasswordBtn!.frame = CGRectMake(0, 0, 44, 44)
        newPasswordBtn!.addTarget(self, action: "addNewPasswrodAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(newPasswordBtn!)
        
        dataSource = MVBPasswordManageDataSource()
        dataSource!.tableViewCellDelegate = self
        
        passwordListTableView = UITableView(frame: CGRectMake(20, 64, 280, 400), style: UITableViewStyle.Plain)
        passwordListTableView!.tableFooterView = UIView()
        passwordListTableView!.tableHeaderView = UIView()
        passwordListTableView!.rowHeight = 44
        passwordListTableView!.delegate = self
        passwordListTableView!.dataSource = dataSource
        passwordListTableView!.registerClass(MVBPasswordRecordCell.self, forCellReuseIdentifier: MVBPasswordManageViewController.Static.pwRecordCellId)
        passwordListTableView!.registerClass(MVBPasswordRecordDetailCell.self, forCellReuseIdentifier: MVBPasswordManageViewController.Static.pwRecordDetailCellId)
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
                print("网络不可用")
                SVProgressHUD.showInfoWithStatus("网络不可用")
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
                print("3G")
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                print("wifi")
            default:
                print("未知状态")
            }
        }
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
}

//  MARK: Private
extension MVBPasswordManageViewController {
    func reloadData() {
        if (dataSource!.passwordIdList != nil) {
            return
        }
        
        SVProgressHUD.showWithStatus("加载列表")
        //  先获取id列表
        dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
            //  成功后继续请求每个id对应的具体data
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
            //  失败有两种可能：没网；新的用户，并没有id列表
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
    
    func configurePullToRefresh() {
        passwordListTableView!.showPullToRefreshView = true
        
        let textArray: NSArray = ["下拉刷新", "松手刷新", "正在刷新", "刷新成功", "刷新失败"]
        
        textArray.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
            let tipsLabel = UILabel(frame: CGRectMake(0, 10, 200, 40))
            tipsLabel.textAlignment = NSTextAlignment.Center
            tipsLabel.backgroundColor = UIColor.whiteColor()
            tipsLabel.text = textArray[idx] as? String
            self.passwordListTableView!.pullToRefreshView.customRefreshView(tipsLabel, forState: MQPullToRefreshState(rawValue: idx)!)
        }
        
        passwordListTableView!.addActionHandlerOnPullToRefreshView(MQPullToRefreshType.Top, triggerDistance: 60) { [unowned self] () -> Void in
            //  先获取id列表
            self.dataSource!.queryPasswordIdList { [unowned self] (succeed) -> Void in
                //  成功后继续请求每个id对应的具体data
                if succeed == true {
                    self.dataSource?.queryPasswordDataList({ [unowned self] (succeed) -> Void in
                        if succeed == true {
                            self.passwordListTableView!.reloadData()
                        }
                        self.passwordListTableView!.pullToRefreshView.refreshSucceed(succeed, duration: 0.5)
                    })
                }
                //  失败有两种可能：没网；新的用户，并没有id列表
                else {
                    self.dataSource!.queryCreatePasswordIdList({ [unowned self] (succeed) -> Void in
                        if succeed == true {
                            self.passwordListTableView!.pullToRefreshView.refreshDone()
                        }
                        else {
                            self.passwordListTableView!.pullToRefreshView.refreshSucceed(succeed, duration: 0.5)
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
        let newPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
        newPasswordView.frame = CGRectMake(0, -260, self.view.frame.width, 260)
        newPasswordView.createButton.addTarget(self, action: "confirmCreateNewPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newPasswordVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newPasswordView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newPasswordVc!.maskView.backgroundColor = UIColor.clearColor()
        newPasswordVc!.delegate = self
        //  设置显示动画
        newPasswordVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(newPasswordView.frame, 0, 260)
            self.newPasswordVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        //  显示关闭动画
        newPasswordVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newPasswordVc!.contentView.frame = CGRectOffset(newPasswordView.frame, 0, -260)
             self.newPasswordVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
        newPasswordVc!.showWithAnimated(true, completion: nil)
        newPasswordView.titleTextView.becomeFirstResponder()
    }
    
    /**
    确认新增密码条目事件
    */
    func confirmCreateNewPasswordAction(sender: AnyObject!) {
        let contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        dataSource!.queryAddPasswordRecord(MVBPasswordRecordModel(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text), complete: { [unowned self]  (succeed) -> Void in
            self.dataSource!.expandingIndexPath = nil
            self.dataSource!.expandedIndexPath = nil
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
            })
        })
    }
    
    /**
    确认更新密码条目事件
    */
    func confirmUpdataPasswordAction(sender: AnyObject!) {
        let contentView = newPasswordVc!.contentView as! MVBNewPasswordView
        let recordModel: MVBPasswordRecordModel = dataSource!.fetchPasswordRecord(operateCellIndex)
        recordModel.update(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
        dataSource!.queryUpdatePasswordRecord(recordModel, complete: { [unowned self] (succeed) -> Void in
            self.dataSource!.expandingIndexPath = nil
            self.dataSource!.expandedIndexPath = nil
            self.passwordListTableView!.reloadData()
            self.newPasswordVc!.dismissWithAnimated(true, completion: { () -> Void in
            })
        })
    }
}

//  MARK: UITableViewDelegate
extension MVBPasswordManageViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //  如果是站看的详细cell
        if (dataSource!.expandedIndexPath != nil && dataSource!.expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            return 60
        }
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //  如果点击的是detailCell 就不响应点击
        if cell.reuseIdentifier == MVBPasswordManageViewController.Static.pwRecordDetailCellId {
            return
        }
        
        //  如果点击的是titleCell 就先看当前有没有侧滑出的，如果有侧滑出的，就先收起侧滑；没有侧滑出的就响应展开。
        let visiableCells: NSArray = tableView.visibleCells
        for cell in visiableCells {
            if (cell is MVBPasswordRecordCell && !cell.isUtilityButtonsHidden())  {
                cell.hideUtilityButtonsAnimated(true)
                return
            }
        }
        
        //  最后响应点击展开
        let actualIndexPath = dataSource!.convertToActualIndexPath(indexPath)
        let theExpandedIndexPath: NSIndexPath? = dataSource!.expandedIndexPath
        
        if dataSource!.expandingIndexPath != nil && actualIndexPath.compare(dataSource!.expandingIndexPath!) == NSComparisonResult.OrderedSame {
            dataSource!.expandingIndexPath = nil
            dataSource!.expandedIndexPath = nil
        }
        else {
            dataSource!.expandingIndexPath = actualIndexPath
            dataSource!.expandedIndexPath = NSIndexPath(forRow: dataSource!.expandingIndexPath!.row + 1, inSection: dataSource!.expandingIndexPath!.section)
        }
        
        tableView.beginUpdates()
        if theExpandedIndexPath != nil {
            tableView.deleteRowsAtIndexPaths([theExpandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        }
        if dataSource!.expandedIndexPath != nil {
            tableView.insertRowsAtIndexPaths([dataSource!.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        }
        tableView.endUpdates()
    }
}

//  MARK: SWTableViewCellDelegate
extension MVBPasswordManageViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if let recordCell = cell as? MVBPasswordRecordCell {
            //  点击编辑按键
            if index == 0 {
                if passwordListTableView!.editing == false {
                    passwordListTableView!.deselectRowAtIndexPath(recordCell.indexPath, animated: true)
                }
                operateCellIndex = recordCell.indexPath.row //  记录操作的哪个cell
                let recordModel: MVBPasswordRecordModel = dataSource!.fetchPasswordRecord(recordCell.indexPath.row)
                let detailPasswordView = NSBundle.mainBundle().loadNibNamed("MVBNewPasswordView", owner: nil, options: nil)[0] as! MVBNewPasswordView
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
                    self.newPasswordVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
                }
                //  显示关闭动画
                newPasswordVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
                    self.newPasswordVc!.contentView.frame = CGRectOffset(detailPasswordView.frame, 0, -260)
                    self.newPasswordVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
                }
                newPasswordVc!.showWithAnimated(true, completion: nil)
                detailPasswordView.titleTextView.becomeFirstResponder()
            }
            //  点击删除按键
            if index == 1 {
                dataSource!.queryDeletePasswordRecord(recordCell.indexPath.row, complete: { [unowned self] (succeed) -> Void in
                    self.passwordListTableView!.beginUpdates()
                    self.passwordListTableView!.deleteRowsAtIndexPaths([recordCell.indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    if self.dataSource!.expandedIndexPath != nil {
                        self.passwordListTableView!.deleteRowsAtIndexPaths([self.dataSource!.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
                    }
                    self.dataSource!.expandedIndexPath = nil
                    self.dataSource!.expandingIndexPath = nil
                    self.passwordListTableView!.endUpdates()
                })
            }
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {

    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, scrollingToState state: SWCellState) {
        if let _ = cell as? MVBPasswordRecordCell {
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
