//
//  Purchase.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation

struct Purchase: Codable {
    var to: UserWrapper!
    var from: UserWrapper!
    var item: ItemWrapper!
    var code: String!
    var redeemed: Bool!
    var date: String
}
