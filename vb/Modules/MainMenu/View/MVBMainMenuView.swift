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
    @IBOutlet var describeLbel: UILabel!
    @IBOutlet weak var detailScrollView: UIScrollView!
    //  下面这四条约束都是会自动改变的
    @IBOutlet weak var autoLeftGap: NSLayoutConstraint!     //  这条约束是右侧的标杆。detailScrollView 和 containerView的右侧都和它对齐
    @IBOutlet weak var centerX: NSLayoutConstraint!

    override func awakeFromNib() {
        self.baseConfigure()
    }
    
    func baseConfigure() {
        self.backgroundColor = UIColor.whiteColor()
        headBackgroundImageView.userInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        autoLeftGap.constant = -(UIWindow.windowSize().width - self.frame.width)
        centerX.constant = (UIWindow.windowSize().width - w) / 2 - 30
    }
    
    deinit {
        print("\(self.dynamicType) deinit", terminator: "")
    }
}
