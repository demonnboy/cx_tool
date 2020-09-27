//
//  Date + extension.swift
//  cx_tool
//
//  Created by Demon on 2020/9/25.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation

extension Date {
    
    public func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public func isSameDay(date: Date?) -> Bool {
        guard let d = date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: d)
    }
    
    /// 秒级
    public static func getCurrentSecondInterval() -> Int {
        let time = Date().timeIntervalSince1970
        let second = Int(time)
        return second
    }
    
    /// 毫秒级
    public static func getCurrentTimeInterval() -> Int {
        let time = Date().timeIntervalSince1970
        let mill = Int(time*1000)
        return mill
    }
}
