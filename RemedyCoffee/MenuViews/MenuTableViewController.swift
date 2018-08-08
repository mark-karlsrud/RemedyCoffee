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
    var items = [ItemCategory: [ItemWrapper]]()
    let SectionHeaderHeight: CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        setBackground(atLocation: "coffee_beans.png")
        self.ref = Database.database().reference()
        
        self.items[.espresso] = [ItemWrapper]()
        self.items[.drip] = [ItemWrapper]()
        self.items[.coffeeFree] = [ItemWrapper]()
        self.items[.food] = [ItemWrapper]()
        
        loadItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ItemCategory.total.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Using Swift's optional lookup we first check if there is a valid section of table.
        // Then we check that for the section there is data that goes with.
        if let tableSection = ItemCategory(rawValue: section), let data = items[tableSection] {
            return data.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we wanted to always show a section header regardless of whether or not there were rows in it,
        // then uncomment this line below:
        //return SectionHeaderHeight
        // First check if there is a valid section of table.
        // Then we check that for the section there is more than 1 row.
        if let tableSection = ItemCategory(rawValue: section), let data = items[tableSection], data.count > 0 {
            return SectionHeaderHeight
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.3529411765, blue: 0.1921568627, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        if let tableSection = ItemCategory(rawValue: section) {
            switch tableSection {
                case .espresso:
                    label.text = "Espresso Based"
                case .drip:
                    label.text = "Drip"
                case .coffeeFree:
                    label.text = "Coffee Free"
                case .food:
                    label.text = "Food"
                default:
                    label.text = ""
                }
        }
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        if let tableSection = ItemCategory(rawValue: indexPath.section), let item = items[tableSection]?[indexPath.row] {
            cell.descriptionLabel.text = item.item.description
            cell.priceLabel.text = item.item.value.toCurrency()
        }
        
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
                    self.items[itemWrapper.item.category]?.append(itemWrapper)
                } catch let error {
                    print(error)
                }
            }
            
            //sort the items
            for (category, _) in self.items {
                self.items[category]?.sort(by: { (item1, item2) -> Bool in
                    return item1.item.index! < item2.item.index!
                })
            }
            self.tableView.reloadData()
            self.tableView.activityStopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ItemViewController {
            let vc = segue.destination as? ItemViewController
            vc?.item = items[ItemCategory(rawValue: (self.tableView.indexPathForSelectedRow?.section)!)!]?[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
