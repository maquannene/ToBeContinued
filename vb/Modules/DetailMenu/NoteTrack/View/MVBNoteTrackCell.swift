//
//  MVBNoteTrackCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SWTableViewCell

class MVBNoteTrackCell: SWTableViewCell {

    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    lazy var topSeparateLine: CALayer = CALayer()
    lazy var bottomSeparateLine: CALayer = CALayer()
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topSeparateLine.backgroundColor = UIColor.grayColor().CGColor
        layer.addSublayer(topSeparateLine)
        bottomSeparateLine.backgroundColor = UIColor.grayColor().CGColor
        layer.addSublayer(bottomSeparateLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topSeparateLine.frame = CGRectMake(0, 0, w, 0.5)
        bottomSeparateLine.frame = CGRectMake(0, h - 0.5, w, 0.5)
    }

    deinit {
        print("\(self.dynamicType) deinit")
    }
}

// MARK: Public
extension MVBNoteTrackCell {
    func configureWithNoteTrackModel(noteTrackModel: MVBNoteTrackModel) -> Void {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        self.contentLabel!.text = noteTrackModel.title
        self.rightUtilityButtons = rightButtons() as [AnyObject]
        self.setRightUtilityButtons(self.rightUtilityButtons, withButtonWidth: 70)
    }
}

// MARK: Private
extension MVBNoteTrackCell {
    private func rightButtons() -> NSArray {
        let rightButtons: NSMutableArray = NSMutableArray()
        rightButtons.sw_addUtilityButtonWithColor(UIColor.lightGrayColor(), title: "编辑")
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
        return rightButtons
    }
}


