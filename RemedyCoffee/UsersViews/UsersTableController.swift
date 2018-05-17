//
//  ShowUsersController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/31/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class UsersTableController: UITableViewController {
    var ref: DatabaseReference!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        self.ref = Database.database().reference()
        loadUsers()
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
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadUsers() {
        self.ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                guard let childSnap = child as? DataSnapshot else { return }
                do {
                    let user = try childSnap.decode(User.self)
                    self.users += [user]
                } catch let error {
                    print(error)
                }
            }
            self.tableView.reloadData()
            self.view.activityStopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UserViewController {
            let vc = segue.destination as? UserViewController
            vc?.user = users[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
