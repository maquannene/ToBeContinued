//
//  MVBMainMenuView.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MVBMainMenuView: UIView {
    
    @IBOutlet var headBackgroundImageView: UIImageView!
    @IBOutlet var headImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var beyondViewRightGap: NSLayoutConstraint!
    @IBOutlet weak var headBgRightGap: NSLayoutConstraint!
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
        super.layoutSubviews()
        headBgRightGap.constant = -(getScreenSize().width - self.frame.width)
        beyondViewRightGap.constant = -(getScreenSize().width - self.frame.width)
    }
    deinit {
        println("\(self.dynamicType) deinit")
    }
}
