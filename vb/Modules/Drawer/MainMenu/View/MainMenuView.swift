//
//  MainMenuView.swift
//  vb
//
//  Created by 马权 on 6/21/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

class MainMenuView: UIView {
    
    @IBOutlet weak var headBackgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var describeLbel: UILabel!
    
    @IBOutlet weak var headImageView: UIImageView! {
        didSet {
            headImageView.layer.borderWidth = 0
            headImageView.layer.cornerRadius = 2
        }
    }
    
    @IBOutlet weak var menuTableView: UITableView! {
        didSet {
            menuTableView.backgroundColor = RGBA(0, 0, 0, 0)
            menuTableView.separatorStyle = .None
            menuTableView.tableFooterView = {
                let view = UIView()
                view.backgroundColor = UIColor.greenColor()
                return view
            } ()
        }
    }
    
    //  下面这四条约束都是会自动改变的
    @IBOutlet weak var autoRightGap: NSLayoutConstraint!     //  这条约束是右侧的标杆。detailScrollView 和 containerView的右侧都和它对齐
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
        autoRightGap.constant = -(UIWindow.windowSize().width - self.frame.width)
        centerX.constant = (UIWindow.windowSize().width - w) / 2 - 30
    }
    
    deinit {
        print("\(self.dynamicType) deinit\n", terminator: "")
    }
    
}
