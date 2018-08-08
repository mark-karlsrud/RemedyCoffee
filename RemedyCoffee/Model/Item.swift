//
//  Item.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation

struct Item: Codable {
    var description: String?
    var size: String?
    var value: Double!
    var imageName: String?
    var index: Int32?
    var category: ItemCategory!
}

enum ItemCategory: Int, Codable {
    case espresso = 0, drip, coffeeFree, food, total
}
