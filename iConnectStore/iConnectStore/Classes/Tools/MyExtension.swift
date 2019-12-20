//
//  DateExtension.swift
//  iConnectStore
//
//  Created by 快游 on 2019/12/19.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Foundation
import Cocoa

extension Date {
    
    func dateConvertString(_ dateFormat:String="yyyy-MM-dd") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date.components(separatedBy: " ").first!
    }
}

extension NSColor {
    
    static func darkBlackColor() -> NSColor {
        
        return NSColor.init(white: 0.28, alpha: 1)
    }
    
    static func lightBlackColor() -> NSColor {
        
        return NSColor.init(white: 0.35, alpha: 1)
    }
    
    static func grayBackgroundColor() -> NSColor {
        
        return NSColor.init(white: 0.5, alpha: 1)
    }
    
    static func mainColor() -> NSColor {
        
        return NSColor(red:0.00, green:0.63, blue:0.78, alpha:1.00)
    }
    
    static func bgColor() -> NSColor {
        
        return NSColor(red:0.00, green:0.63, blue:0.78, alpha:1.00)
    }
    
    static func titleBarBackgroundColor() -> NSColor {
        
        return NSColor.init(white: 0.5, alpha: 0.8)
    }
    
    static func titleWhiteColor() -> NSColor {
        
        return NSColor.init(white: 0.95, alpha: 0.8)
    }
}

extension NSView {
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
}

extension NSView {
    public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
}

extension NSView {
    public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
}

extension NSView {
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
}

extension NSView {
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
}
