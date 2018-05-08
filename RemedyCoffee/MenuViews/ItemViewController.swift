//
//  PurchaserViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/12/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase

class ItemViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var ref: DatabaseReference!
    var item: ItemWrapper?
    var purchase: Purchase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        descriptionLabel.text = item?.item.description
        valueLabel.text = item?.item.value.description
        sizeLabel.text = item?.item.size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buyClick(_ sender: Any) {
        let toUser = User(name: "Mark", phone: nil, isAdmin: false)
        let to = UserWrapper(id: "user1", user: toUser)
        let fromUser = User(name: "Bob", phone: nil, isAdmin: false)
        let from = UserWrapper(id: "user2", user: fromUser)
        let purchaseCode = UUID().uuidString
        let redeemed = false
        let date = Date().toDateAndTime()
        purchase = Purchase(to: to, from: from, item: item, code: purchaseCode, redeemed: redeemed, date: date)
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(purchase).toDict()
            let childUpdates = ["/purchases/\(purchaseCode)/": json,
                                "/userPurchases/\(String(describing: purchase?.from.id!))/\(purchaseCode)/" : json,
                                "/userCredits/\(String(describing: purchase?.to.id!))/\(purchaseCode)/" : json]
            self.ref.updateChildValues(childUpdates)
//            self.navigationController?.pushViewController(PurchasesTableController(), animated: true)
        } catch let error {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PurchaseViewController {
            let vc = segue.destination as? PurchaseViewController
            vc?.purchase = purchase
        }
    }
}
