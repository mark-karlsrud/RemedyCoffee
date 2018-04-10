//
//  ViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/14/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Saves user profile information to user database
    func saveUserInfo(_ user: Firebase.User, withName name: String, withFacebookId fbId: String) {
        
        // Create a change request
//        self.showSpinner {}
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        
        // Commit profile changes to server
        changeRequest?.commitChanges() { (error) in
            
//            self.hideSpinner {}
            
            if let error = error {
//                self.showMessagePrompt(error.localizedDescription)
                return
            }
            
            // [START basic_write]
            self.ref.child("users").child(user.uid).setValue(["name": name, "fbId": fbId])
            // [END basic_write]
        }
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
            let permissionDictionary = [
                "fields" : "id,name,first_name,last_name,gender,email,birthday,picture.type(large)"
                //"locale" : "en_US"
            ]
            FBSDKGraphRequest(graphPath: "/me", parameters: permissionDictionary)
                .start(completionHandler:  { (connection, result, error) in
                    if error == nil {
                        self.ref = Database.database().reference()
                        //                        onCompletion(result as? Dictionary<String, AnyObject>, nil)
                        let fbData = result as? Dictionary<String, AnyObject>
                        self.saveUserInfo(user!, withName: fbData!["name"] as! String, withFacebookId: fbData!["id"] as! String)
                    } else {
                        //                        onCompletion(nil, error as NSError?)
                    }
                })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

