//
//  PurchaserViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/12/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = item?.description
        valueLabel.text = item?.value.description
        sizeLabel.text = item?.size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
