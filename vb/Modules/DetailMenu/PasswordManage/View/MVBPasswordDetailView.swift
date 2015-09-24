//
//  MVBPasswordDetailView.swift
//  vb
//
//  Created by 马权 on 9/22/15.
//  Copyright © 2015 maquan. All rights reserved.
//

class MVBPasswordDetailView: UIView {

    @IBOutlet weak var contentLabel: UILabel!
    
    var contentText: String {
        set {
            let size: CGSize = (newValue as NSString).boundingRectWithSize(
                CGSize(width: self.w - 40, height: CGFloat(MAXFLOAT)),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: contentLabel.font],
                context: nil).size
            contentLabel.text = newValue
            self.h = size.height + 40 + 1
        }
        
        get {
            return contentLabel.text!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    deinit {
        print("\(self.dynamicType) deinit")
    }
    
}
