//
//  UIView+extension.swift
//  cx_tool
//
//  Created by Demon on 2020/9/30.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            if self.top == newValue { return }
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            if self.left == newValue { return }
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return self.frame.maxX
        }
        set {
            if self.right == newValue { return }
            var frame = self.frame
            frame.origin.x = newValue - self.width
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.frame.maxY
        }
        set {
            if self.bottom == newValue { return }
            var frame = self.frame
            frame.origin.y = newValue - self.height
            self.frame = frame
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            if self.width == newValue { return }
            var frame = self.frame
            frame.size.width = width
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            if self.height == newValue { return }
            var frame = self.frame
            frame.size.height = self.height
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            if self.centerX == newValue { return }
            self.center = CGPoint(x: newValue, y: self.centerY)
        }
    }
    
    public var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            if self.centerY == newValue { return }
            self.center = CGPoint(x: self.centerX, y: newValue)
        }
    }
}

