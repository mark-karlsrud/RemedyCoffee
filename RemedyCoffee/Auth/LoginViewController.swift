//
//  LoginViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 5/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebasePhoneAuthUI
import Contacts

class LoginViewController: UIViewController, FUIAuthDelegate {
    var ref: DatabaseReference!
    var auth: Auth?
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scanButton.isHidden = true
        addBackground(atLocation: "coffee_cheers")
        
        self.auth = Auth.auth()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let user = self.auth?.currentUser {
            onSignIn(user.uid)
        } else {
            needsToSignIn()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPhoneNumber(_ sender: Any) {
//        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
//        phoneProvider.signIn(withPresenting: currentlyVisibleController, phoneNumber: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            onSignIn(user.uid)
            print(user.phoneNumber!)
            print(UIDevice.current.name)
            
    //        print(PhoneContacts.getContacts())
            
            // Create a change request
            //        self.showSpinner {}
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    //        changeRequest?.displayName = name
            
            // Commit profile changes to server
            changeRequest?.commitChanges() { (error) in
                
                //            self.hideSpinner {}
                
                if let error = error {
                    //                self.showMessagePrompt(error.localizedDescription)
                    return
                }
                if let phone = user.phoneNumber {
                    // [START basic_write]
                    self.ref.child("users").child(user.uid).setValue(["name": UIDevice.current.name, "phone": phone, "isAdmin" : false])
                    // [END basic_write]
                }
            }
        }
    }
    
    func onSignIn(_ uid: String) {
        print("signed in")
        loginButton.setTitle("Sign Out", for: .normal)
        self.ref = Database.database().reference()
        
        self.ref.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            do {
                let user = try snapshot.decode(User.self)
                print(user)
                self.checkIfAdmin(user)
            } catch let error {
                print(error)
            }
        })
    }
    
    func checkIfAdmin(_ user: User) {
        if user.isAdmin != nil {
            scanButton.isHidden = false
        }
    }
    
    func needsToSignIn() {
        loginButton.setTitle("Sign In", for: .normal)
        FUIAuth.defaultAuthUI()?.delegate = self
        let phoneProvider = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        FUIAuth.defaultAuthUI()?.providers = [phoneProvider]
        
        //            let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try self.auth?.signOut()
            needsToSignIn()
        } catch let error {
            print("error signing out")
            print(error)
        }
    }
}
