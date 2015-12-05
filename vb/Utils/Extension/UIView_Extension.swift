//
//  UIView_Extension.swift
//  vb
//
//  Created by 马权 on 9/22/15.
//  Copyright © 2015 maquan. All rights reserved.
//

extension UIView {
    
    public var x: CGFloat {
        get {
            return frame.minX
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var y: CGFloat {
        get {
            return frame.minY
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    public var w: CGFloat {
        get {
            return frame.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    public var h: CGFloat {
        get {
            return frame.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    public var left: CGFloat {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    
    public var top: CGFloat {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    
    public var right: CGFloat {
        return x + w
    }
    
    public var bottom: CGFloat {
        return y + h
    }
    
}

struct ViewGlanceContent : OptionSetType {
    var rawValue: UInt
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static let ClassName: ViewGlanceContent = ViewGlanceContent(rawValue: 1 << 0)
    static let Point: ViewGlanceContent = ViewGlanceContent(rawValue: 1 << 1)
    static let Frame: ViewGlanceContent = ViewGlanceContent(rawValue: 1 << 2)
    static let Description: ViewGlanceContent = ViewGlanceContent(rawValue: 1 << 3)
}


//  MARK: ViewGlance
extension UIView {
    
    func viewGlance(maxLevel: NSInteger, logContent: ViewGlanceContent) {
        self.viewGlance(maxLevel, longContent: logContent, currentLevel: 0)
    }
    
    func viewGlance(maxLevel: NSInteger, longContent: ViewGlanceContent, currentLevel: NSInteger) {                var levelLog = String()
        for _ in 0 ..< currentLevel {
            levelLog = levelLog.stringByAppendingString(" | ")
        }
        
        var desLog = String()
        if longContent.contains(.Description) {
            desLog = desLog.stringByAppendingString(self.description)
        }
        else {
            if (longContent.contains(.ClassName)) {
                desLog = desLog.stringByAppendingString("\(self.dynamicType)")
            }
            if (longContent.contains(.Point)) {
                desLog = desLog.stringByAppendingString(NSString(format: "%p", self) as String)
            }
            if (longContent.contains(.Frame)) {
                desLog = desLog.stringByAppendingString(NSStringFromCGRect(self.frame) as String)
            }
        }

        print(levelLog + " " + desLog)
        
        if  (currentLevel + 1) > maxLevel {
            return
        }

        for view in self.subviews {
            view.viewGlance(maxLevel, longContent: longContent, currentLevel: currentLevel + 1)
        }
        
    }
    
}
