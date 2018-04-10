//
//  UserWrapper.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/9/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import Firebase

struct UserWrapper {
    var id: String!
    var user: User
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let user = User(data: dict["user"]!) else { return nil }
        
        self.id = id
        self.user = user
    }
    
    init?(data dictionary: Any) {
        guard let dict = dictionary as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let user = User(data: dict["user"]!) else { return nil }
        
        self.id = id
        self.user = user
    }
}
