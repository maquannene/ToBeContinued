//
//  MVBPasswordRecordDetailCell.swift
//  vb
//
//  Created by 马权 on 7/16/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBPasswordRecordDetailCell: UITableViewCell {

}

// MARK: Public
extension MVBPasswordRecordDetailCell {
    func configureWithRecord(record: MVBPasswordRecordModel) -> Void {
        self.textLabel!.text = "detail: \(record.title)"
    }
}