//
//  Purchase.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import Firebase

struct Purchase {
    var to: UserWrapper!
    var from: UserWrapper!
    var item: ItemWrapper!
    var code: String!
    var redeemed: Bool!
    var date: String
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let to = UserWrapper(data: dict["to"]!) else { return nil }
        guard let from = UserWrapper(data: dict["from"]!) else { return nil }
        guard let item = ItemWrapper(data: dict["item"]!) else { return nil }
        guard let code = dict["code"] as? String else { return nil }
        guard let redeemed = dict["redeemed"] as? Bool else { return nil }
        guard let date = dict["date"] as? String else { return nil }

        self.to = to
        self.from = from
        self.item = item
        self.code = code
        self.redeemed = redeemed
        self.date = date
    }
    
    init?(data dictionary: Any) {
        guard let dict = dictionary as? [String: Any] else { return nil }
        guard let to = UserWrapper(data: dict["to"]!) else { return nil }
        guard let from = UserWrapper(data: dict["from"]!) else { return nil }
        guard let item = ItemWrapper(data: dict["item"]!) else { return nil }
        guard let code = dict["code"] as? String else { return nil }
        guard let redeemed = dict["redeemed"] as? Bool else { return nil }
        guard let date = dict["date"] as? String else { return nil }
        
        self.to = to
        self.from = from
        self.item = item
        self.code = code
        self.redeemed = redeemed
        self.date = date
    }
}
