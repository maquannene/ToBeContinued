//
//  MVBNoteTrackViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

//  MARK: LeftCycle
class MVBNoteTrackViewController: MVBDetailBaseViewController {
    
    struct Static {
        static let noteTrackCellId = MVBNoteTrackCell.ClassName
        static let noteTrackDetailCellId = MVBNoteTrackDetailCell.ClassName
    }

    @IBOutlet weak var noteTrackListTableView: UITableView!
    var dataSource: MVBNoteTrackDataSource!

    var newNoteTrackVc: MQMaskController?
    var operateCellIndex: Int = -1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        //  全屏的回滑手势
//        self.fd_interactivePopDisabled = true
//        self.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = getScreenSize().width
        //  基础设置
        view.backgroundColor = UIColor.redColor()
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewNoteTrackAction:")
        
        //  初始化数据源
        dataSource = MVBNoteTrackDataSource()
        
        //  设置tableView
        configurePullToRefresh()
        noteTrackListTableView.tableFooterView = UIView()
        noteTrackListTableView.registerNib(UINib(nibName: Static.noteTrackCellId, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Static.noteTrackCellId)
        noteTrackListTableView.registerNib(UINib(nibName: Static.noteTrackDetailCellId, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Static.noteTrackDetailCellId)
        noteTrackListTableView.header.beginRefreshing()

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
extension MVBNoteTrackViewController {
    
    func configurePullToRefresh() {
        //  注意这一句的内存泄露 如果不加 [unowned self] 就会内存泄露
        //  泄漏原因为retain cycle 即 self->noteTrackListTableView->header->refreshingBlock->self
        noteTrackListTableView.header = MJRefreshNormalHeader() { [unowned self] in
            //  如果获取失败，就创建新的
            self.dataSource.queryFindNoteTrackIdList { [unowned self] succeed in
                guard succeed == true else {
                    self.dataSource.queryCreateNoteTrackIdList { [unowned self] succeed in
                        self.noteTrackListTableView.header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的noteTrack存在缓存中
                self.dataSource.queryNoteTrackList { [unowned self] succeed in
                    guard succeed == true else { self.noteTrackListTableView.header.endRefreshing(); return }
                    self.noteTrackListTableView.reloadData()
                    self.noteTrackListTableView.header.endRefreshing()
                }
            }
        }
    }
}

//  MARK: Action
extension MVBNoteTrackViewController {
    /**
    新增密码条目
    */
    func addNewNoteTrackAction(sender: AnyObject!) {
        let newNoteTrackView = NSBundle.mainBundle().loadNibNamed("MVBNewNoteTrackView", owner: nil, options: nil)[0] as! MVBNewNoteTrackView
        newNoteTrackView.frame = CGRectMake(0, -260, self.view.frame.width, 260)
        newNoteTrackView.createButton.setTitle("创建", forState: UIControlState.Normal)
        newNoteTrackView.createButton.addTarget(self, action: "confirmCreateNewNoteTrackAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackView.cancelButton.addTarget(self, action: "cancelAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        newNoteTrackVc!.delegate = self
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, 0, 260)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        //  显示关闭动画
        newNoteTrackVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, 0, -260)
             self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
        newNoteTrackVc!.showWithAnimated(true, completion: nil)
        newNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    编辑密码条目
    */
    func editNoteTrackAction(indexPath: NSIndexPath) {
        if noteTrackListTableView.editing == false {
            noteTrackListTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        operateCellIndex = indexPath.row //  记录操作的哪个cell
        let noteTrackModel: MVBNoteTrackModel = dataSource.fetchNoteTrackModel(operateCellIndex)
        let detailNoteTrackView = NSBundle.mainBundle().loadNibNamed("MVBNewNoteTrackView", owner: nil, options: nil)[0] as! MVBNewNoteTrackView
        detailNoteTrackView.configureData(noteTrackModel.title, detailContent: noteTrackModel.detailContent)
        detailNoteTrackView.frame = CGRectMake(0, -260, self.view.frame.width, 260)
        detailNoteTrackView.createButton.setTitle("更新", forState: UIControlState.Normal)
        detailNoteTrackView.createButton.addTarget(self, action: "confirmUpdataNoteTrackAction:", forControlEvents: UIControlEvents.TouchUpInside)
        detailNoteTrackView.cancelButton.addTarget(self, action: "cancelAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: detailNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.delegate = self
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(detailNoteTrackView.frame, 0, 260)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        //  显示关闭动画
        newNoteTrackVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(detailNoteTrackView.frame, 0, -260)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
        newNoteTrackVc!.showWithAnimated(true, completion: nil)
        detailNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    删除密码条目
    */
    func deleteNoteTrackAction(indexPath: NSIndexPath) {
        dataSource.queryDeleteNoteTrackModel(indexPath.row) { [unowned self] (succeed) -> Void in
            self.noteTrackListTableView.beginUpdates()
            self.noteTrackListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            if self.dataSource.expandedIndexPath != nil {
                self.noteTrackListTableView.deleteRowsAtIndexPaths([self.dataSource.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
            }
            self.dataSource.expandedIndexPath = nil
            self.dataSource.expandingIndexPath = nil
            self.noteTrackListTableView.endUpdates()
        }
    }
    
    /**
    显示详细密码页面
    */
    func showDetailNoteTrackAction(sender: AnyObject!) {
        let noteTrackModel: MVBNoteTrackModel = dataSource.fetchNoteTrackModel(dataSource.expandingIndexPath!.row)
        let newNoteTrackView = NSBundle.mainBundle().loadNibNamed("MVBNewNoteTrackView", owner: nil, options: nil)[1] as! MVBNoteTrackDetailView
        newNoteTrackView.frame = CGRectMake(10, self.view.h, self.view.frame.width - 20, 0)
        newNoteTrackView.contentText = noteTrackModel.detailContent
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        newNoteTrackVc!.delegate = self
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, 0, -(self.newNoteTrackVc!.contentView.h + 10))
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
        //  显示关闭动画
        newNoteTrackVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, 0, self.newNoteTrackVc!.contentView.h + 10)
//            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
        newNoteTrackVc!.showWithAnimated(true, completion: nil)
    }
    
    /**
    确认新增密码条目事件
    */
    func confirmCreateNewNoteTrackAction(sender: AnyObject!) {
        let contentView = newNoteTrackVc!.contentView as! MVBNewNoteTrackView
        dataSource.queryAddNoteTrack(MVBNoteTrackModel(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text), complete: { [unowned self]  (succeed) -> Void in
            self.dataSource.expandingIndexPath = nil
            self.dataSource.expandedIndexPath = nil
//            self.noteTrackListTableView.reloadData()
            self.newNoteTrackVc!.dismissWithAnimated(true) {
                self.noteTrackListTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
        })
    }
    
    /**
    确认更新密码条目事件
    */
    func confirmUpdataNoteTrackAction(sender: AnyObject!) {
        let contentView = newNoteTrackVc!.contentView as! MVBNewNoteTrackView
        let noteTrackModel: MVBNoteTrackModel = dataSource.fetchNoteTrackModel(operateCellIndex)
        noteTrackModel.update(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
        dataSource.queryUpdateNoteTrackModel(noteTrackModel) { [unowned self] (succeed) -> Void in
            self.dataSource.expandingIndexPath = nil
            self.dataSource.expandedIndexPath = nil
            self.noteTrackListTableView.reloadData()
            self.newNoteTrackVc!.dismissWithAnimated(true, completion: nil)
        }
    }
    
    func cancelAction(sender: AnyObject!) {
        self.newNoteTrackVc!.dismissWithAnimated(true, completion: nil)
    }
    
}

//  MARK: UITableViewDelegate
extension MVBNoteTrackViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //  如果是站看的详细cell
        if (dataSource.expandedIndexPath != nil && dataSource.expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            return 60
        }
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //  如果点击的是detailCell 就不响应点击
        if let _ = cell as? MVBNoteTrackDetailCell {
            return
        }
        
        //  如果点击的是titleCell 就先判断有没有侧滑滑出的
        //  如果有侧滑出的，就先收起侧滑；没有侧滑出的就响应展开。
        let visiableCells: NSArray = tableView.visibleCells
        for cell in visiableCells {
            if (cell is MVBNoteTrackCell && !cell.isUtilityButtonsHidden())  {
                cell.hideUtilityButtonsAnimated(true)
                return
            }
        }
        
        //  最后响应点击展开
        let actualIndexPath = dataSource.convertToActualIndexPath(indexPath)
        let theExpandedIndexPath: NSIndexPath? = dataSource.expandedIndexPath
        
        if dataSource.expandingIndexPath != nil && actualIndexPath.compare(dataSource.expandingIndexPath!) == NSComparisonResult.OrderedSame {
            dataSource.expandingIndexPath = nil
            dataSource.expandedIndexPath = nil
        }
        else {
            dataSource.expandingIndexPath = actualIndexPath
            dataSource.expandedIndexPath = NSIndexPath(forRow: dataSource.expandingIndexPath!.row + 1, inSection: dataSource.expandingIndexPath!.section)
        }
        
        tableView.beginUpdates()
        if theExpandedIndexPath != nil {
            tableView.deleteRowsAtIndexPaths([theExpandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        }
        if dataSource.expandedIndexPath != nil {
            tableView.insertRowsAtIndexPaths([dataSource.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        }
        tableView.endUpdates()
        
        //  如果点击的是最下面的，就滚到最下面。
        if dataSource.expandedIndexPath != nil && dataSource.expandedIndexPath!.row == dataSource.noteTrackModelList.count {
            tableView.scrollToRowAtIndexPath(dataSource.expandedIndexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
}

// MARK: UITableViewDataSource
extension MVBNoteTrackViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.expandedIndexPath != nil {
            return dataSource.noteTrackModelList.count + 1
        }
        else {
            return dataSource.noteTrackModelList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let actualIndexPath = dataSource.convertToActualIndexPath(indexPath)
        let noteTrackModel: MVBNoteTrackModel = dataSource.noteTrackModelList[actualIndexPath.row] as! MVBNoteTrackModel
        //  如果是展开的detailCell
        if (dataSource.expandedIndexPath != nil && dataSource.expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            let detailCell: MVBNoteTrackDetailCell = tableView.dequeueReusableCellWithIdentifier(MVBNoteTrackViewController.Static.noteTrackDetailCellId) as! MVBNoteTrackDetailCell
            detailCell.configureWithNoteTrackModel(noteTrackModel)
            detailCell.detailButton.addTarget(self, action: "showDetailNoteTrackAction:", forControlEvents: UIControlEvents.TouchUpInside)
            return detailCell
        }
        else {
            let titleCell: MVBNoteTrackCell = tableView.dequeueReusableCellWithIdentifier(MVBNoteTrackViewController.Static.noteTrackCellId) as! MVBNoteTrackCell
            titleCell.configureWithNoteTrackModel(noteTrackModel)
            titleCell.delegate = self
            return titleCell
        }
    }
    
}

//  MARK: SWTableViewCellDelegate
extension MVBNoteTrackViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        let indexPath = self.noteTrackListTableView.indexPathForCell(cell)
        //  点击编辑按键
        if index == 0 {
            editNoteTrackAction(indexPath!)
        }
        //  点击删除按键
        if index == 1 {
            deleteNoteTrackAction(indexPath!)
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {

    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, scrollingToState state: SWCellState) {
        if let _ = cell as? MVBNoteTrackCell {
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
extension MVBNoteTrackViewController: MQMaskControllerDelegate {
    func maskControllerWillDismiss(maskController: MQMaskController!) {
        if let contentView = maskController.contentView as? MVBNewNoteTrackView {
            if contentView.titleTextView.isFirstResponder() {
                contentView.titleTextView.resignFirstResponder()
            }
            if contentView.detailContentTextView.isFirstResponder() {
                contentView.detailContentTextView.resignFirstResponder()
            }
        }
    }
}
