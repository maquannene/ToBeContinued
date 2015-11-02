//
//  MQPictureBrowserView.swift
//  vb
//
//  Created by 马权 on 11/2/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MQPictureBrowserView: UIView {

    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.backgroundColor = RGBA(red: 0, green: 0, blue: 0, alpha: 0.2)
            saveButton.layer.cornerRadius = 2
            saveButton.layer.borderColor = UIColor.whiteColor().CGColor
            saveButton.layer.borderWidth = 1
        }
    }
    
}
