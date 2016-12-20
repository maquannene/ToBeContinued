//
//  NSObject_Extension.swift
//  vb
//
//  Created by 马权 on 9/22/15.
//  Copyright © 2015 maquan. All rights reserved.
//

public extension NSObject {
    
    //  类方法，类也是对象，这里的self 指的就是 这个类
    public class var RealClassName: String {
        return String(describing: self)
    }
    
    public class var ClassName: String {
        return NSStringFromClass(self)
    }
    
    //  实例方法
    public var RealClassName: String {
        return String(describing: type(of: self))
    }
    
    public var ClassName: String {
        return NSStringFromClass(type(of: self))
    }
    
}
