
//
//  MVBNewPasswordView.swift
//  vb
//
//  Created by 马权 on 6/29/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBNewPasswordView: UIView {
   
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var detailContentTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureData(title: String, detailContent: String) {
        titleTextField.text = title
        detailContentTextField.text = detailContent
    }
    
    deinit {
        println("\(self.dynamicType) deinit")
    }
}
