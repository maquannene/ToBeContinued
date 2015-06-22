//
//  MVBMainMenuView.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import UIKit

class MVBMainMenuView: UIView {
    
    @IBOutlet var headBackgroundImageView: UIImageView!
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        self.baseConfigure()
    }
    
    func baseConfigure() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
