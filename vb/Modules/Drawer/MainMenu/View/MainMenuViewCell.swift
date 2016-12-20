//
//  MainMenuViewCell.swift
//  vb
//
//  Created by 马权 on 11/8/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MainMenuViewCell: UITableViewCell {
    
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
        bottomSeparateLine.frame = CGRect(x: 0, y: h - 0.5, width: w, height: 0.5)
    }
    
}

//  MARK: Private
extension MainMenuViewCell {
    
    func baseConfigure() {
        bottomSeparateLine.backgroundColor = UIColor.gray.cgColor
        layer.addSublayer(bottomSeparateLine)
    }
    
}

//  MARK: Public
extension MainMenuViewCell {
    
    func configure() {
        self.selectionStyle = .none
    }
    
}
