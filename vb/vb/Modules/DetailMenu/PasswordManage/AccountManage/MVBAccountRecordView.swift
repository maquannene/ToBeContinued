//
//  MVBAccountRecordView.swift
//  vb
//
//  Created by 马权 on 6/26/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBAccountRecordView: UIView {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    
    deinit {
        print("\(self.dynamicType) deinit", appendNewline: false)
    }
}
