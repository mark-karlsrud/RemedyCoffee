//
//  User.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/31/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import Firebase

struct User {
    var name: String
    var photoUrl: String?
    var fbId: String?
    var phone: Int?
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let name = dict["name"] as? String else { return nil }
//        guard let photoUrl = dict["photoUrl"] as? String else { return nil }
//        guard let fbId = dict["fbId"] as? String else { return nil }
//        guard let phone = dict["phone"] as? Int else { return nil }

        self.name = name
//        self.photoUrl = photoUrl
//        self.fbId = fbId
//        self.phone = phone
    }
    
    init?(data dictionary: Any) {
        guard let dict = dictionary as? [String: Any] else { return nil }
        guard let name = dict["name"] as? String else { return nil }
//        guard let photoUrl = dict["photoUrl"] as? String else { return nil }
//        guard let fbId = dict["fbId"] as? String else { return nil }
//        guard let phone = dict["phone"] as? Int else { return nil }
        
        self.name = name
//        self.photoUrl = photoUrl
//        self.fbId = fbId
//        self.phone = phone
    }
}
