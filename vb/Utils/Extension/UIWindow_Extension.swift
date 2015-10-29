//
//  UIWindow_Extension.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

extension UIWindow {
    
    public class func windowSize() -> CGSize! {
        return UIApplication.sharedApplication().keyWindow!.frame.size
    }
    
}
