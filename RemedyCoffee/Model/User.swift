//
//  User.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/31/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String
    var photoUrl: String?
    var fbId: String?
    var phone: Int?
}
