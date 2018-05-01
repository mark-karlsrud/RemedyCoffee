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
        
        cell.toLabel.text = purchase.to.user.name
        cell.dateLabel.text = purchase.date.toDate().toDateOnly()
        cell.amountLabel.text = purchase.item.item.value.toCurrency()
        
        if (purchase.redeemed) {
            cell.amountLabel.textColor = UIColor.red
        } else {
            cell.amountLabel.textColor = UIColor.green
        }
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadPurchases() {
        self.ref.child("purchases").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                guard let childSnap = child as? DataSnapshot else { return }
                do {
                    let purchase = try childSnap.decode(Purchase.self)
                    self.purchases += [purchase]
                    print(purchase)
                } catch let error {
                    print(error)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PurchaseViewController {
            let vc = segue.destination as? PurchaseViewController
            vc?.purchase = purchases[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}

