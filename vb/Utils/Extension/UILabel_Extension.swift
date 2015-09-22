//
//  UILabel_Extension.swift
//  vb
//
//  Created by 马权 on 9/22/15.
//  Copyright © 2015 maquan. All rights reserved.
//

extension UILabel {
    
    /**
    判断UILabel.text是否显示不全 出现了...
    */
    func isTruncated(var maxSize: CGSize = CGSizeZero) -> Bool {
        
        if CGSizeEqualToSize(maxSize, CGSizeZero) {
            maxSize = CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT))
        }
        
        if let string = self.text {
            
            let size: CGSize = (string as NSString).boundingRectWithSize(
                maxSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: self.font],
                context: nil).size
            
            if (size.height > self.bounds.size.height) {
                return true
            }
        }
        
        return false
    }
    
}