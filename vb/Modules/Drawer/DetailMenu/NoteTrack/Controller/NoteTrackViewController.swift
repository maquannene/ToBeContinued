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
import Appear
import MMDrawerController

//  MARK: LeftCycle
class NoteTrackViewController: DetailBaseViewController {
    
    struct Static {
        static let noteTrackCellId = NoteTrackCell.RealClassName
        static let noteTrackDetailCellId = NoteTrackDetailCell.RealClassName
    }
    
    var viewModel: NoteTrackViewModel!
    var newNoteAppear: Appear?
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
        view.backgroundColor = UIColor.red
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addNewNoteTrackAction(_:)))
        
        //  初始化数据源
        viewModel = NoteTrackViewModel()
        
        noteTrackListTableView.tableFooterView = UIView()
        noteTrackListTableView.register(UINib(nibName: Static.noteTrackCellId, bundle: Bundle.main), forCellReuseIdentifier: Static.noteTrackCellId)
        noteTrackListTableView.register(UINib(nibName: Static.noteTrackDetailCellId, bundle: Bundle.main), forCellReuseIdentifier: Static.noteTrackDetailCellId)
        
        //  设置tableView
        noteTrackListTableView.mj_header.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    deinit {
        print("\(type(of: self)) deinit\n", terminator: "")
    }
}

//  MARK: Private
extension NoteTrackViewController {
    
    func configurePullToRefresh()
    {
        //  注意这一句的内存泄露 如果不加 [unowned self] 就会内存泄露
        //  泄漏原因为retain cycle 即 self->noteTrackListTableView->header->refreshingBlock->self
        noteTrackListTableView.mj_header = MJRefreshNormalHeader() { [unowned self] in
            //  获取成功，就逐条请求存储的noteTrack存在缓存中
            self.viewModel.queryNoteTrackListCompletion { [unowned self] succeed in
                guard succeed == true else { self.noteTrackListTableView.mj_header.endRefreshing(); return }
                self.noteTrackListTableView.reloadData()
                self.noteTrackListTableView.mj_header.endRefreshing()
            }
        }
    }
}

//  MARK: Action
extension NoteTrackViewController {
    /**
    新增密码条目
    */
    @objc fileprivate func addNewNoteTrackAction(_ sender: AnyObject!)
    {
        let newNoteTrackView = Bundle.main.loadNibNamed("NewNoteTrackView", owner: nil, options: nil)?[0] as! NewNoteTrackView
        newNoteTrackView.frame = CGRect(x: -(self.view.frame.width - 40), y: 40, width: self.view.frame.width - 40, height: 240)
        newNoteTrackView.createButton.setTitle("创建", for: UIControlState())
        newNoteTrackView.createButton.addTarget(self, action: #selector(NoteTrackViewController.confirmCreateNewNoteTrackAction(_:)), for: UIControlEvents.touchUpInside)
        newNoteTrackView.cancelButton.addTarget(self, action: #selector(NoteTrackViewController.cancelAction(_:)), for: UIControlEvents.touchUpInside)
        newNoteAppear = Appear(dismissType: .tip, contentView: newNoteTrackView)
        newNoteAppear!.delegate = self
        newNoteAppear?.dismissAnimation = { [unowned self] (maskView, contentView) -> Void in
            contentView.frame = newNoteTrackView.frame.offsetBy(dx: self.view.w - 20, dy: 0)
            maskView.backgroundColor = RGBA(255, 255, 255, 0)
        }
        
        newNoteAppear?.showAnimation = { [unowned self] (maskView, contentView) in
            contentView.frame = newNoteTrackView.frame.offsetBy(dx: self.view.w - 20, dy: 0)
            maskView.backgroundColor = RGBA(255, 255, 255, 0.5)
        }
        
        //  设置显示动画
        newNoteAppear!.show(with: .custom)
        newNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    编辑密码条目
    */
    @objc fileprivate func editNoteTrackAction(_ indexPath: IndexPath)
    {
        if noteTrackListTableView.isEditing == false {
            noteTrackListTableView.deselectRow(at: indexPath, animated: true)
        }
        operateCellIndex = indexPath.row //  记录操作的哪个cell
        guard let noteTrackModel = viewModel.fetchNoteTrackModel(operateCellIndex) else { return }
        let detailNoteTrackView = Bundle.main.loadNibNamed("NewNoteTrackView", owner: nil, options: nil)?[0] as! NewNoteTrackView
        detailNoteTrackView.configureData(noteTrackModel.title, detailContent: noteTrackModel.detailContent)
        detailNoteTrackView.frame = CGRect(x: -(self.view.frame.width - 40), y: 40, width: self.view.frame.width - 40, height: 240)
        detailNoteTrackView.createButton.setTitle("更新", for: UIControlState())
        detailNoteTrackView.createButton.addTarget(self, action: #selector(NoteTrackViewController.confirmUpdataNoteTrackAction(_:)), for: UIControlEvents.touchUpInside)
        detailNoteTrackView.cancelButton.addTarget(self, action: #selector(NoteTrackViewController.cancelAction(_:)), for: UIControlEvents.touchUpInside)
        
        newNoteAppear = Appear(dismissType: .tip, contentView: detailNoteTrackView)
        newNoteAppear!.delegate = self
        //  设置显示动画
        newNoteAppear!.showAnimation = { [unowned self] (maskView, contentView) -> Void in
            contentView.frame = detailNoteTrackView.frame.offsetBy(dx: self.view.w - 20, dy: 0)
            maskView.backgroundColor = RGBA(255, 255, 255, 0.8)
        }
        //  显示关闭动画
        newNoteAppear!.dismissAnimation = { [unowned self] (maskView, contentView) -> Void in
            contentView.frame = detailNoteTrackView.frame.offsetBy(dx: self.view.w - 20, dy: 0)
            maskView.backgroundColor = RGBA(255, 255, 255, 0)
        }
        newNoteAppear?.show(with: .custom)
        detailNoteTrackView.titleTextView.becomeFirstResponder()
    }
    
    /**
    删除密码条目
    */
    @objc fileprivate func deleteNoteTrackAction(_ indexPath: IndexPath)
    {
        viewModel.queryDeleteNoteTrackAtIndex(indexPath.row) { [unowned self] (succeed) -> Void in
            self.noteTrackListTableView.beginUpdates()
            self.noteTrackListTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.none)
            if self.viewModel.expandedIndexPath != nil {
                self.noteTrackListTableView.deleteRows(at: [self.viewModel.expandedIndexPath!], with: UITableViewRowAnimation.none)
            }
            self.viewModel.expandedIndexPath = nil
            self.viewModel.expandingIndexPath = nil
            self.noteTrackListTableView.endUpdates()
        }
    }
    
    /**
    显示详细密码页面
    */
    @objc fileprivate func showDetailNoteTrackAction(_ sender: AnyObject!)
    {
        guard let noteTrackModel = viewModel.fetchNoteTrackModel(viewModel.expandingIndexPath!.row) else { return }
        let newNoteTrackView = Bundle.main.loadNibNamed("NewNoteTrackView", owner: nil, options: nil)?[1] as! NoteTrackDetailView
        newNoteTrackView.frame = CGRect(x: 10, y: self.view.h, width: self.view.frame.width - 20, height: 0)
        newNoteTrackView.contentText = noteTrackModel.detailContent
        newNoteAppear = Appear(dismissType: .tip, contentView: newNoteTrackView)
        newNoteAppear!.delegate = self
        //  设置显示动画
        newNoteAppear!.showAnimation = { (maskView, contentView) -> Void in
            contentView.frame = newNoteTrackView.frame.offsetBy(dx: 0, dy: -(contentView.h + 10))
            maskView.backgroundColor = RGBA(0, 0, 0, 0.3)
        }
        //  显示关闭动画
        newNoteAppear!.dismissAnimation = { (maskView, contentView) -> Void in
            contentView.frame = newNoteTrackView.frame.offsetBy(dx: 0, dy: contentView.h + 10)
        }
        newNoteAppear!.show(with: .custom)
    }
    
    /**
    确认新增密码条目事件
    */
    @objc fileprivate func confirmCreateNewNoteTrackAction(_ sender: AnyObject!)
    {
        if let contentView = newNoteAppear?.contentView as? NewNoteTrackView {
            let noteTrackModel = NoteTrackModel(objectId: nil,
                                                identifier: NoteTrackModel.uniqueIdentifier(),
                                                title: contentView.titleTextView.text,
                                                detailContent:
                contentView.detailContentTextView.text)
            viewModel.queryAddNoteTrack(noteTrackModel) { [weak self] (succeed) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.expandingIndexPath = nil
                strongSelf.viewModel.expandedIndexPath = nil
                strongSelf.newNoteAppear!.dismiss(with: .custom)
                    strongSelf.noteTrackListTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    /**
    确认更新 NoteTrack 条目事件
    */
    @objc fileprivate func confirmUpdataNoteTrackAction(_ sender: AnyObject!)
    {
        if let contentView = newNoteAppear?.contentView as? NewNoteTrackView {
            guard let noteTrackModel: NoteTrackModel = viewModel.fetchNoteTrackModel(operateCellIndex)?.mutableCopy() as? NoteTrackModel else { return }
            noteTrackModel.update(contentView.titleTextView.text, detailContent: contentView.detailContentTextView.text)
            viewModel.queryUpdateNoteTrack(noteTrackModel, index: operateCellIndex) { [weak self] (succeed) -> Void in
                guard let strongSelf = self else { return }
                if (succeed == true) {
                    strongSelf.viewModel.expandingIndexPath = nil
                    strongSelf.viewModel.expandedIndexPath = nil
                    strongSelf.noteTrackListTableView.reloadData()
                }
                strongSelf.newNoteAppear!.dismiss(with: .custom)
            }
        }
    }
    
    @objc fileprivate func cancelAction(_ sender: AnyObject!) {
        newNoteAppear?.dismiss(with: .`default`)
    }
    
}

//  MARK: UITableViewDelegate
extension NoteTrackViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //  如果是站看的详细cell
        if (viewModel.expandedIndexPath != nil && (viewModel.expandedIndexPath! as IndexPath).compare(indexPath) == ComparisonResult.orderedSame) {
            return 60
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: false)
        
        //  如果点击的是detailCell 就不响应点击
        if let _ = cell as? NoteTrackDetailCell {
            return
        }
        
        //  如果点击的是titleCell 就先判断有没有侧滑滑出的
        //  如果有侧滑出的，就先收起侧滑；没有侧滑出的就响应展开。
        let visiableCells: NSArray = tableView.visibleCells as NSArray
        for cell in visiableCells {
            if (cell is NoteTrackCell && !(cell as AnyObject).isUtilityButtonsHidden()) {
                (cell as AnyObject).hideUtilityButtons(animated: true)
                return
            }
        }
        
        //  最后响应点击展开
        let actualIndexPath = viewModel.convertToActualIndexPath(indexPath)
        let theExpandedIndexPath: IndexPath? = viewModel.expandedIndexPath as IndexPath?
        
        if viewModel.expandingIndexPath != nil && actualIndexPath?.compare(viewModel.expandingIndexPath!) == ComparisonResult.orderedSame {
            viewModel.expandingIndexPath = nil
            viewModel.expandedIndexPath = nil
        }
        else {
            viewModel.expandingIndexPath = actualIndexPath
            viewModel.expandedIndexPath = IndexPath(row: viewModel.expandingIndexPath!.row + 1, section: viewModel.expandingIndexPath!.section)
        }
        
        tableView.beginUpdates()
        if theExpandedIndexPath != nil {
            tableView.deleteRows(at: [theExpandedIndexPath!], with: UITableViewRowAnimation.automatic)
        }
        if viewModel.expandedIndexPath != nil {
            tableView.insertRows(at: [viewModel.expandedIndexPath! as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        tableView.endUpdates()
        
        //  如果点击的是最下面的，就滚到最下面。
        if viewModel.expandedIndexPath != nil && viewModel.expandedIndexPath!.row == viewModel.noteTrackModelList.count {
            tableView.scrollToRow(at: viewModel.expandedIndexPath! as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
}

// MARK: UITableViewviewModel
extension NoteTrackViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        noNoteTrackTips.isHidden = (viewModel.noteTrackModelList.count > 0)
        if viewModel.expandedIndexPath != nil {
            return viewModel.noteTrackModelList.count + 1
        }
        else {
            return viewModel.noteTrackModelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let actualIndexPath = viewModel.convertToActualIndexPath(indexPath)
        let noteTrackModel: NoteTrackModel = viewModel.noteTrackModelList[actualIndexPath!.row]
        //  如果是展开的detailCell
        if (viewModel.expandedIndexPath != nil && (viewModel.expandedIndexPath! as IndexPath).compare(indexPath) == ComparisonResult.orderedSame) {
            let detailCell: NoteTrackDetailCell = tableView.dequeueReusableCell(withIdentifier: NoteTrackViewController.Static.noteTrackDetailCellId) as! NoteTrackDetailCell
            detailCell.configureWithNoteTrackModel(noteTrackModel)
            detailCell.detailButton.addTarget(self, action: #selector(NoteTrackViewController.showDetailNoteTrackAction(_:)), for: UIControlEvents.touchUpInside)
            return detailCell
        }
        else {
            let titleCell: NoteTrackCell = tableView.dequeueReusableCell(withIdentifier: NoteTrackViewController.Static.noteTrackCellId) as! NoteTrackCell
            titleCell.configureWithNoteTrackModel(noteTrackModel)
            titleCell.delegate = self
            titleCell.slideGestureDelegate = self
            return titleCell
        }
    }
    
}

//  MARK: SWTableViewCellDelegate
extension NoteTrackViewController: SWTableViewCellDelegate, NoteTrackCellSlideGestureDelegate {
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int)
    {
        let indexPath = self.noteTrackListTableView.indexPath(for: cell)
        //  点击编辑按键
        if index == 0 {
            editNoteTrackAction(indexPath!)
        }
        //  点击删除按键
        if index == 1 {
            deleteNoteTrackAction(indexPath!)
        }
    }

    func swipeableTableViewCellDidEndScrolling(_ cell: SWTableViewCell!)
    {
        if cell.isUtilityButtonsHidden() {
            self.mm_drawerController?.openDrawerGestureModeMask = .all
        }
        else {
            self.mm_drawerController?.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
        }
    }

    func slideGestureRecognizerShouldReceiveTouch() -> NSNumber
    {
        for cell in noteTrackListTableView.visibleCells {
            guard cell is NoteTrackCell else { return true }
            if !(cell as! NoteTrackCell).isUtilityButtonsHidden() {
                (cell as! NoteTrackCell).hideUtilityButtons(animated: true)
                return false
            }
        }
        return true
    }
    
}

// MARK: MQMaskControllerDelegate
extension NoteTrackViewController: AppearDelegate {

    func appearWillShow(appear: Appear) {}
    
    func appearDidShow(appear: Appear) {}
    
    func appearWillDismiss(appear: Appear) {
        if let contentView = appear.contentView as? NewNoteTrackView {
            if contentView.titleTextView.isFirstResponder {
                contentView.titleTextView.resignFirstResponder()
            }
            if contentView.detailContentTextView.isFirstResponder {
                contentView.detailContentTextView.resignFirstResponder()
            }
        }
    }
    
    func appearDidDismiss(appear: Appear) {}
}
