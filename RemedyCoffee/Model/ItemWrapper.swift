//
//  UserWrapper.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/9/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import Firebase

struct ItemWrapper {
    var id: String!
    var item: Item
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let item = Item(data: dict["item"]!) else { return nil }
        
        self.id = id
        self.item = item
    }
    
    init?(data dictionary: Any) {
        guard let dict = dictionary as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let item = Item(data: dict["item"]!) else { return nil }
        
        self.id = id
        self.item = item
    }
}

