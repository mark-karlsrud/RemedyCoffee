//
//  DateFormat.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import UIKit
import Firebase

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
    
    func toTimeOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
}

extension Double {
    func toCurrency() -> String {
        return String(format: "$%.02f", self)
    }
}

extension UIViewController {
    func addBackground(atLocation fileLocation: String) {
        // screen width and height:
        let background = UIImage(named: fileLocation)
        var imageView : UIImageView!
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = self.view.center
        imageView.alpha = 0.5
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
}

extension UITableViewController {
    func setBackground(atLocation fileLocation: String) {
        let background = UIImage(named: fileLocation)
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.5
        self.tableView.backgroundView = imageView
    }
}

extension DataSnapshot {
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let childValue = self.value as! [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: childValue, options: [])
        let item = try JSONDecoder().decode(type.self, from: jsonData)
        return item;
    }
}

extension Data {
    func toDict() throws -> NSDictionary {
        return try JSONSerialization.jsonObject(with: self, options: []) as! NSDictionary
    }
}
