//
//  NoteTrackViewController.swift
//  vb
//
//  Created by 马权 on 6/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SVProgressHUD
import AFNetworking
import MJRefresh
import SWTableViewCell
import MQMaskController

//  MARK: LeftCycle
class NoteTrackViewController: DetailBaseViewController {
    
    struct Static {
        static let noteTrackCellId = NoteTrackCell.RealClassName
        static let noteTrackDetailCellId = NoteTrackDetailCell.RealClassName
    }
    
    var viewModel: NoteTrackViewModel!
    
    var newNoteTrackVc: MQMaskController?
    @IBOutlet weak var noNoteTrackTips: UILabel!
    var operateCellIndex: Int = -1
    
    @IBOutlet weak var noteTrackListTableView: UITableView! {
        didSet {
            configurePullToRefresh()
        }
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        //  基础设置
        view.backgroundColor = UIColor.redColor()
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(addNewNoteTrackAction(_:)))
        
        //  初始化数据源
        viewModel = NoteTrackViewModel()
        
        noteTrackListTableView.tableFooterView = UIView()
        noteTrackListTableView.registerNib(UINib(nibName: Static.noteTrackCellId, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Static.noteTrackCellId)
        noteTrackListTableView.registerNib(UINib(nibName: Static.noteTrackDetailCellId, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Static.noteTrackDetailCellId)
        
        //  设置tableView
        noteTrackListTableView.mj_header.beginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (netWorkState: AFNetworkReachabilityStatus) -> Void in
            switch netWorkState {
            case AFNetworkReachabilityStatus.NotReachable:
                print("网络不可用")
                SVProgressHUD.showInfoWithStatus("网络不可用")
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
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
}

//  MARK: Private
extension NoteTrackViewController {
    
    func configurePullToRefresh()
    {
        //  注意这一句的内存泄露 如果不加 [unowned self] 就会内存泄露
        //  泄漏原因为retain cycle 即 self->noteTrackListTableView->header->refreshingBlock->self
        noteTrackListTableView.mj_header = MJRefreshNormalHeader() { [unowned self] in
            //  如果获取失败，就创建新的
            self.viewModel.queryFindNoteTrackIdListCompletion { [unowned self] succeed in
                guard succeed == true else {
                    self.viewModel.queryCreateNoteTrackIdListCompletion { [unowned self] succeed in
                        self.noteTrackListTableView.mj_header.endRefreshing()
                    }
                    return
                }
                
                //  获取成功，就逐条请求存储的noteTrack存在缓存中
                self.viewModel.queryNoteTrackListCompletion { [unowned self] succeed in
                    guard succeed == true else { self.noteTrackListTableView.mj_header.endRefreshing(); return }
                    self.noteTrackListTableView.reloadData()
                    self.noteTrackListTableView.mj_header.endRefreshing()
                }
            }
        }
    }
    
}

//  MARK: Action
extension NoteTrackViewController {
    /**
    新增密码条目
    */
    @objc private func addNewNoteTrackAction(sender: AnyObject!)
    {
        let newNoteTrackView = NSBundle.mainBundle().loadNibNamed("NewNoteTrackView", owner: nil, options: nil)[0] as! NewNoteTrackView
        newNoteTrackView.frame = CGRectMake(-(self.view.frame.width - 40), 40, self.view.frame.width - 40, 240)
        newNoteTrackView.createButton.setTitle("创建", forState: UIControlState.Normal)
        newNoteTrackView.createButton.addTarget(self, action: #selector(NoteTrackViewController.confirmCreateNewNoteTrackAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackView.cancelButton.addTarget(self, action: #selector(NoteTrackViewController.cancelAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        newNoteTrackVc!.delegate = self
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, self.view.w - 20, 0)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(255, 255, 255, 0.5)
        }
        //  显示关闭动画
        newNoteTrackVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, self.view.w - 20, 0)
             self.newNoteTrackVc!.maskView.backgroundColor = RGBA(255, 255, 255, 0)
        }
        newNoteTrackVc!.showWithAnimated(true, completion: nil)
        newNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    编辑密码条目
    */
    @objc private func editNoteTrackAction(indexPath: NSIndexPath)
    {
        if noteTrackListTableView.editing == false {
            noteTrackListTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        operateCellIndex = indexPath.row //  记录操作的哪个cell
        guard let noteTrackModel = viewModel.fetchNoteTrackModel(operateCellIndex) else { return }
        let detailNoteTrackView = NSBundle.mainBundle().loadNibNamed("NewNoteTrackView", owner: nil, options: nil)[0] as! NewNoteTrackView
        detailNoteTrackView.configureData(noteTrackModel.title, detailContent: noteTrackModel.detailContent)
        detailNoteTrackView.frame = CGRectMake(-(self.view.frame.width - 40), 40, self.view.frame.width - 40, 240)
        detailNoteTrackView.createButton.setTitle("更新", forState: UIControlState.Normal)
        detailNoteTrackView.createButton.addTarget(self, action: #selector(NoteTrackViewController.confirmUpdataNoteTrackAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        detailNoteTrackView.cancelButton.addTarget(self, action: #selector(NoteTrackViewController.cancelAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: detailNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.delegate = self
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(detailNoteTrackView.frame, self.view.w - 20, 0)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(255, 255, 255, 0.8)
        }
        //  显示关闭动画
        newNoteTrackVc!.setCloseAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(detailNoteTrackView.frame, self.view.w - 20, 0)
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(255, 255, 255, 0)
        }
        newNoteTrackVc!.showWithAnimated(true, completion: nil)
        detailNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    删除密码条目
    */
    @objc private func deleteNoteTrackAction(indexPath: NSIndexPath)
    {
        viewModel.queryDeleteNoteTrackAtIndex(indexPath.row) { [unowned self] (succeed) -> Void in
            self.noteTrackListTableView.beginUpdates()
            self.noteTrackListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            if self.viewModel.expandedIndexPath != nil {
                self.noteTrackListTableView.deleteRowsAtIndexPaths([self.viewModel.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
            }
            self.viewModel.expandedIndexPath = nil
            self.viewModel.expandingIndexPath = nil
            self.noteTrackListTableView.endUpdates()
        }
    }
    
    /**
    显示详细密码页面
    */
    @objc private func showDetailNoteTrackAction(sender: AnyObject!)
    {
        guard let noteTrackModel = viewModel.fetchNoteTrackModel(viewModel.expandingIndexPath!.row) else { return }
        let newNoteTrackView = NSBundle.mainBundle().loadNibNamed("NewNoteTrackView", owner: nil, options: nil)[1] as! NoteTrackDetailView
        newNoteTrackView.frame = CGRectMake(10, self.view.h, self.view.frame.width - 20, 0)
        newNoteTrackView.contentText = noteTrackModel.detailContent
        newNoteTrackVc = MQMaskController(maskController: MQMaskControllerType.TipDismiss, withContentView: newNoteTrackView, contentCenter: false, delayTime: 0)
        //  设置初始状态
        newNoteTrackVc!.maskView.backgroundColor = UIColor.clearColor()
        newNoteTrackVc!.delegate = self
        //  设置显示动画
        newNoteTrackVc!.setShowAnimationState { [unowned self] (maskView, contentView) -> Void in
            self.newNoteTrackVc!.contentView.frame = CGRectOffset(newNoteTrackView.frame, 0, -(self.newNoteTrackVc!.contentView.h + 10))
            self.newNoteTrackVc!.maskView.backgroundColor = RGBA(0, 0, 0, 0.3)
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
    @objc private func confirmCreateNewNoteTrackAction(sender: AnyObject!)
    {
        let contentView = newNoteTrackVc!.contentView as! NewNoteTrackView
        let noteTrackModel = NoteTrackModel(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
        viewModel.queryAddNoteTrack(noteTrackModel, complete: { [weak self]  (succeed) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.expandingIndexPath = nil
            strongSelf.viewModel.expandedIndexPath = nil
//            self.noteTrackListTableView.reloadData()
            strongSelf.newNoteTrackVc!.dismissWithAnimated(true) {
                strongSelf.noteTrackListTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
        })
    }
    
    /**
    确认更新 NoteTrack 条目事件
    */
    @objc private func confirmUpdataNoteTrackAction(sender: AnyObject!)
    {
        let contentView = newNoteTrackVc!.contentView as! NewNoteTrackView
        guard let noteTrackModel: NoteTrackModel = viewModel.fetchNoteTrackModel(operateCellIndex)?.mutableCopy() as? NoteTrackModel else { return }
        noteTrackModel.update(title: contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
        viewModel.queryUpdateNoteTrack(noteTrackModel, index: operateCellIndex) { [weak self] (succeed) -> Void in
            guard let strongSelf = self else { return }
            if (succeed == true) {
                strongSelf.viewModel.expandingIndexPath = nil
                strongSelf.viewModel.expandedIndexPath = nil
                strongSelf.noteTrackListTableView.reloadData()
            }
            strongSelf.newNoteTrackVc!.dismissWithAnimated(true, completion: nil)
        }
    }
    
    @objc private func cancelAction(sender: AnyObject!) {
        self.newNoteTrackVc!.dismissWithAnimated(true, completion: nil)
    }
    
}

//  MARK: UITableViewDelegate
extension NoteTrackViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        //  如果是站看的详细cell
        if (viewModel.expandedIndexPath != nil && viewModel.expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            return 60
        }
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //  如果点击的是detailCell 就不响应点击
        if let _ = cell as? NoteTrackDetailCell {
            return
        }
        
        //  如果点击的是titleCell 就先判断有没有侧滑滑出的
        //  如果有侧滑出的，就先收起侧滑；没有侧滑出的就响应展开。
        let visiableCells: NSArray = tableView.visibleCells
        for cell in visiableCells {
            if (cell is NoteTrackCell && !cell.isUtilityButtonsHidden()) {
                cell.hideUtilityButtonsAnimated(true)
                return
            }
        }
        
        //  最后响应点击展开
        let actualIndexPath = viewModel.convertToActualIndexPath(indexPath)
        let theExpandedIndexPath: NSIndexPath? = viewModel.expandedIndexPath
        
        if viewModel.expandingIndexPath != nil && actualIndexPath.compare(viewModel.expandingIndexPath!) == NSComparisonResult.OrderedSame {
            viewModel.expandingIndexPath = nil
            viewModel.expandedIndexPath = nil
        }
        else {
            viewModel.expandingIndexPath = actualIndexPath
            viewModel.expandedIndexPath = NSIndexPath(forRow: viewModel.expandingIndexPath!.row + 1, inSection: viewModel.expandingIndexPath!.section)
        }
        
        tableView.beginUpdates()
        if theExpandedIndexPath != nil {
            tableView.deleteRowsAtIndexPaths([theExpandedIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        if viewModel.expandedIndexPath != nil {
            tableView.insertRowsAtIndexPaths([viewModel.expandedIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        tableView.endUpdates()
        
        //  如果点击的是最下面的，就滚到最下面。
        if viewModel.expandedIndexPath != nil && viewModel.expandedIndexPath!.row == viewModel.noteTrackModelList.count {
            tableView.scrollToRowAtIndexPath(viewModel.expandedIndexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
}

// MARK: UITableViewviewModel
extension NoteTrackViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        noNoteTrackTips.hidden = viewModel.noteTrackModelList.count > 0;
        if viewModel.expandedIndexPath != nil {
            return viewModel.noteTrackModelList.count + 1
        }
        else {
            return viewModel.noteTrackModelList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let actualIndexPath = viewModel.convertToActualIndexPath(indexPath)
        let noteTrackModel: NoteTrackModel = viewModel.noteTrackModelList[actualIndexPath.row]
        //  如果是展开的detailCell
        if (viewModel.expandedIndexPath != nil && viewModel.expandedIndexPath!.compare(indexPath) == NSComparisonResult.OrderedSame) {
            let detailCell: NoteTrackDetailCell = tableView.dequeueReusableCellWithIdentifier(NoteTrackViewController.Static.noteTrackDetailCellId) as! NoteTrackDetailCell
            detailCell.configureWithNoteTrackModel(noteTrackModel)
            detailCell.detailButton.addTarget(self, action: #selector(NoteTrackViewController.showDetailNoteTrackAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return detailCell
        }
        else {
            let titleCell: NoteTrackCell = tableView.dequeueReusableCellWithIdentifier(NoteTrackViewController.Static.noteTrackCellId) as! NoteTrackCell
            titleCell.configureWithNoteTrackModel(noteTrackModel)
            titleCell.delegate = self
            titleCell.slideGestureDelegate = self
            return titleCell
        }
    }
    
}

//  MARK: SWTableViewCellDelegate
extension NoteTrackViewController: SWTableViewCellDelegate, NoteTrackCellSlideGestureDelegate {
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int)
    {
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

    func swipeableTableViewCellDidEndScrolling(cell: SWTableViewCell!)
    {
        if cell.isUtilityButtonsHidden() {
            self.mm_drawerController?.openDrawerGestureModeMask = .All
        }
        else {
            self.mm_drawerController?.openDrawerGestureModeMask = .None
        }
    }

    func slideGestureRecognizerShouldReceiveTouch() -> NSNumber
    {
        for cell in noteTrackListTableView.visibleCells {
            guard cell is NoteTrackCell else { return true }
            if !(cell as! NoteTrackCell).isUtilityButtonsHidden() {
                (cell as! NoteTrackCell).hideUtilityButtonsAnimated(true)
                return false
            }
        }
        return true
    }
    
}

// MARK: MQMaskControllerDelegate
extension NoteTrackViewController: MQMaskControllerDelegate {
    
    func maskControllerWillDismiss(maskController: MQMaskController!)
    {
        if let contentView = maskController.contentView as? NewNoteTrackView {
            if contentView.titleTextView.isFirstResponder() {
                contentView.titleTextView.resignFirstResponder()
            }
            if contentView.detailContentTextView.isFirstResponder() {
                contentView.detailContentTextView.resignFirstResponder()
            }
        }
    }
    
}
