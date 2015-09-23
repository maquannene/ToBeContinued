//
//  MVBPasswordRecordCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordCell: SWTableViewCell {

    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var lineLeftGap: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    deinit {
        print("\(self.dynamicType) deinit")
    }
}

// MARK: Public
extension MVBPasswordRecordCell {
    func configureWithRecord(record: MVBPasswordRecordModel) -> Void {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        self.contentLabel!.text = record.title
        self.rightUtilityButtons = rightButtons() as [AnyObject]
        self.setRightUtilityButtons(self.rightUtilityButtons, withButtonWidth: 70)
    }
}

// MARK: Private
extension MVBPasswordRecordCell {
    private func rightButtons() -> NSArray {
        let rightButtons: NSMutableArray = NSMutableArray()
        rightButtons.sw_addUtilityButtonWithColor(UIColor.lightGrayColor(), title: "编辑")
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
        return rightButtons
    }
}


