//
//  UserTableViewCell.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/31/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
//    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

