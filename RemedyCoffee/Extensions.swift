//
//  DateFormat.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation

let format = "yyyy/MMM/dd HH:mm:ss"

extension Date {
    func toDateAndTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toDateOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/YYYY"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return dateFormatter.date(from: self)!
    }
}

extension Double {
    func toCurrency() -> String {
        return String(format: "$%.02f", self)
    }
}
