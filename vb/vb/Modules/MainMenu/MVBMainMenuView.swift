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
    
    @IBOutlet weak var rightGap: NSLayoutConstraint!
    override func awakeFromNib() {
        self.baseConfigure()
    }
    
    func baseConfigure() {
        self.backgroundColor = UIColor.whiteColor()
        headBackgroundImageView.userInteractionEnabled = true
    }
    override var frame: CGRect {
        didSet {
            println("23")
        }
    }
    override func layoutSubviews() {
//        if getScreenSize().width > self.frame.width {
            rightGap.constant = -(getScreenSize().width - self.frame.width)
//        }
//        else {
        
//        }
        super.layoutSubviews()
    }
    deinit {
        println("\(self.dynamicType) deinit")
    }
}
