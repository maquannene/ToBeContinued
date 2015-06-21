//
//  MVBPasswordRecordCell.swift
//  vb
//
//  Created by 马权 on 6/19/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

import SLExpandableTableView

protocol UIExpandingTableViewCell : NSObjectProtocol {
    
    var loading: Bool { get set }
    
    var expansionStyle: UIExpansionStyle { get }
    func setExpansionStyle(style: UIExpansionStyle, animated: Bool)
}

class MVBPasswordRecordCell: UITableViewCell {
    
    var isLoading: Bool = false
    var style: UIExpansionStyle = UIExpansionStyleCollapsed
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.grayColor()
    }
}

extension MVBPasswordRecordCell: UIExpandingTableViewCell {
    
    var loading: Bool {
        set {
            self.isLoading = newValue
        }
        get {
            return isLoading
        }
    }
    
    var expansionStyle: UIExpansionStyle {
        return style
    }
    
    func setExpansionStyle(style: UIExpansionStyle, animated: Bool) {
        if self.style.value != style.value {
            self.style = style
        }
    }
}
