//
//  Item.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import Firebase

struct Item {
    var description: String?
    var size: String?
    var value: Double!
    
    init?(snapshot: DataSnapshot) {
        self.init(data: snapshot.value!)
    }
    
    init?(data: Any) {
        guard let dict = data as? [String:Any] else { return nil }
        guard let description = dict["description"] as? String else { return nil }
        guard let size = dict["size"] as? String else { return nil }
        guard let value = dict["value"] as? Double else { return nil }
        
        self.description = description
        self.size = size
        self.value = value
    }
}
