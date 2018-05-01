//
//  MenuTableViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/12/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class MenuTableController: UITableViewController {
    var ref: DatabaseReference!
    var items = [ItemWrapper]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground(atLocation: "coffee_on_table.jpg")
        self.ref = Database.database().reference()
        loadItems()
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
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let item = items[indexPath.row]
        
        cell.descriptionLabel.text = item.item.description
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadItems() {
        self.ref.child("menu").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                guard let childSnap = child as? DataSnapshot else { return }
                do {
                    let item = try childSnap.decode(Item.self)
                    let itemWrapper = ItemWrapper(id: childSnap.key, item: item)
                    self.items += [itemWrapper]
                    print(item)
                } catch let error {
                    print(error)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ItemViewController {
            let vc = segue.destination as? ItemViewController
            vc?.item = items[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
