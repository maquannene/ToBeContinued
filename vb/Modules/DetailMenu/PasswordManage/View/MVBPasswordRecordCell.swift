//
//  MVBPasswordRecordCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordCell: SWTableViewCell {

    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    lazy var line: CALayer = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        line.backgroundColor = UIColor.grayColor().CGColor
        layer.addSublayer(line)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        line.frame = CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5)
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
        self.textLabel!.text = "title: \(record.title)"
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
