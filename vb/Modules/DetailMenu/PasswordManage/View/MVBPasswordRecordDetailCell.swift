//
//  MVBPasswordRecordDetailCell.swift
//  vb
//
//  Created by 马权 on 7/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordDetailCell: UITableViewCell {

    lazy var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
    
}

// MARK: Public
extension MVBPasswordRecordDetailCell {
    func configureWithRecord(record: MVBPasswordRecordModel) -> Void {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.cyanColor()
        self.textLabel!.text = "detail: \(record.detailContent)"
    }
}