//
//  MVBMainMenuViewCell.swift
//  vb
//
//  Created by 马权 on 11/8/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBMainMenuViewCell: UITableViewCell {
    
    lazy var bottomSeparateLine: CALayer = CALayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.baseConfigure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomSeparateLine.frame = CGRectMake(0, h - 0.5, w, 0.5)
    }
    
}

//  MARK: Private
extension MVBMainMenuViewCell {
    
    func baseConfigure() {
        bottomSeparateLine.backgroundColor = UIColor.grayColor().CGColor
        layer.addSublayer(bottomSeparateLine)
    }
    
}

//  MARK: Public
extension MVBMainMenuViewCell {
    
    func configure() {
        self.selectionStyle = .None
    }
    
}
