//
//  MVBPasswordRecordCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordCell: SWTableViewCell {

    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.grayColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}

// MARK: Public
extension MVBPasswordRecordCell {
    func configureWithRecord(record: MVBPasswordRecordModel) -> Void {
        self.textLabel!.text = "title: \(record.title)"
        self.rightUtilityButtons = rightUtilityButtons
    }
}

// MARK: Private
extension MVBPasswordRecordCell {
    private func rightButtons() -> NSArray {
        var rightButtons: NSMutableArray = NSMutableArray()
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "编辑")
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
        return rightButtons
    }
}
