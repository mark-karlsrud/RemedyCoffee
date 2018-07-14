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
    var isSignedIn: Bool = false
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        self.scanButton.isHidden = true
        addBackground(atLocation: "coffee_menu")
        
        self.auth = Auth.auth()
        
        if let user = self.auth?.currentUser {
            onSignIn(user.uid)
        } else {
            needsToSignIn()
        }
        self.view.activityStopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self.view)
        
        let xPerc = touchPoint.x / self.view.frame.maxX
        let yPerc = touchPoint.y / self.view.frame.maxY
//        print(xPerc)
//        print(yPerc)
        
        if !isSignedIn {
            needsToSignIn()
        } else if xPerc > 0.42 && xPerc < 0.72 && yPerc > 0.38 && yPerc < 0.58 {
            //first cup pressed
//            print("first")
            let purchasesView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchasesTable") as! PurchasesTableController
            self.navigationController?.pushViewController(purchasesView, animated: true)
        } else if xPerc > 0.32 && xPerc < 0.66 && yPerc > 0.66 && yPerc < 0.80 {
            //second cup pressed
//            print("second")
            let menuView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuTable") as! MenuTableController
            self.navigationController?.pushViewController(menuView, animated: true)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            onSignIn(user.uid)
            
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
        isSignedIn = true
        
        loginButton.title = "Sign Out"
        
        self.ref = Database.database().reference()
//        myPurchasesButton.isHidden = false
//        buyItemButton.isHidden = false
        self.ref.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            do {
                let user = try snapshot.decode(User.self)
                self.checkIfAdmin(user)
            } catch let error {
                print(error)
            }
        })
    }
    
    func checkIfAdmin(_ user: User) {
        if let isAdmin = user.isAdmin {
            scanButton.isHidden = !isAdmin
        }
    }
    
    func needsToSignIn() {
//        myPurchasesButton.isHidden = true
//        buyItemButton.isHidden = true
        self.ref = nil
        
        loginButton.title = "Sign In"
        
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
            isSignedIn = false
        } catch let error {
            print("error signing out")
            print(error)
        }
    }
}
