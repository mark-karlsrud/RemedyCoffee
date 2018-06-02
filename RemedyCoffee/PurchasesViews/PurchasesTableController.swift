//
//  PurchasesTableController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class PurchasesTableController: UITableViewController {
    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    var purchases = [Purchase]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        setBackground(atLocation: "coffee_on_table.jpg")
        self.ref = Database.database().reference()
        loadPurchases()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PurchasesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PurchasesTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PurchasesTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let purchase = purchases[indexPath.row]
        
        cell.itemDescriptionLabel.text = purchase.item.item.description
        cell.dateLabel.text = purchase.date.toDate().toShortDate()
        cell.amountLabel.text = purchase.item.item.value.toCurrency()
        
        if (purchase.redeemed) {
            cell.amountLabel.textColor = #colorLiteral(red: 0.6133681536, green: 0, blue: 0, alpha: 1)
        } else {
            cell.amountLabel.textColor = #colorLiteral(red: 0, green: 0.5714713931, blue: 0.1940918863, alpha: 1)
        }
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadPurchases() {
        self.ref.child("userPurchases").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                guard let childSnap = child as? DataSnapshot else { return }
                do {
                    let purchase = try childSnap.decode(Purchase.self)
                    self.purchases += [purchase]
                 } catch let error {
                    print(error)
                }
            }
            self.tableView.reloadData()
            self.view.activityStopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PurchaseViewController {
            let vc = segue.destination as? PurchaseViewController
            vc?.purchase = purchases[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}

