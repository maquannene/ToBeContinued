//
//  UIScreen_Extension.swift
//  vb
//
//  Created by 马权 on 9/25/15.
//  Copyright © 2015 maquan. All rights reserved.
//

extension UIScreen {
    public class func screenSize() -> CGSize! {
        return UIScreen.mainScreen().bounds.size
    }
}
