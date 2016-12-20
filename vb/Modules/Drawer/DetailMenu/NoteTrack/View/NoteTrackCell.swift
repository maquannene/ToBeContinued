//
//  NoteTrackCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SWTableViewCell

protocol NoteTrackCellSlideGestureDelegate: NSObjectProtocol {
    func slideGestureRecognizerShouldReceiveTouch() -> NSNumber
}

protocol NoteTrackCellDataSource: class {
    var titleStr: String! { get }
}

class NoteTrackCell: SWTableViewCell {

    weak var noteTrackModel: NoteTrackCellDataSource?
    lazy var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    lazy var topSeparateLine: CALayer = CALayer()
    lazy var bottomSeparateLine: CALayer = CALayer()
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    weak var slideGestureDelegate: NoteTrackCellSlideGestureDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        baseConfigure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseConfigure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topSeparateLine.frame = CGRect(x: 0, y: 0, width: w, height: 0.5)
        bottomSeparateLine.frame = CGRect(x: 0, y: h - 0.5, width: w, height: 0.5)
    }

    deinit {
        print("\(type(of: self)) deinit\n")
    }
    
}

// MARK: Public
extension NoteTrackCell {
    
    func configureWithNoteTrackModel(_ noteTrackModel: NoteTrackCellDataSource!) -> Void {
        self.noteTrackModel = noteTrackModel
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.white
        self.contentLabel!.text = noteTrackModel.titleStr
        self.rightUtilityButtons = rightButtons() as [AnyObject]
        self.setRightUtilityButtons(self.rightUtilityButtons, withButtonWidth: 70)
    }
}

// MARK: Private
extension NoteTrackCell {
    
    fileprivate func baseConfigure() {
        topSeparateLine.backgroundColor = UIColor.gray.cgColor
        layer.addSublayer(topSeparateLine)
        bottomSeparateLine.backgroundColor = UIColor.gray.cgColor
        layer.addSublayer(bottomSeparateLine)
    }
    
    fileprivate func rightButtons() -> NSArray {
        let rightButtons: NSMutableArray = NSMutableArray()
        rightButtons.sw_addUtilityButton(with: UIColor.lightGray, title: "编辑")
        rightButtons.sw_addUtilityButton(with: UIColor.red, title: "删除")
        return rightButtons
    }
    
    func slideGestureRecognizerShouldReceiveTouch() -> NSNumber {
        return (slideGestureDelegate?.slideGestureRecognizerShouldReceiveTouch())!
    }
    
}
