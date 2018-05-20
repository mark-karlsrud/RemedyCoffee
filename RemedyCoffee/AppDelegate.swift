//
//  AppDelegate.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/14/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let purchaseCode = url.host!
        //1. Add to purchases
        //2. Go to purchase view
        
        let navController = self.window?.rootViewController as! UINavigationController;

        var controllers = [UIViewController]()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        let purchaseTable = storyboard.instantiateViewController(withIdentifier: "PurchasesTable") as! PurchasesTableController
        let purchaseView = storyboard.instantiateViewController(withIdentifier: "PurchaseView") as! PurchaseViewController
        
        //If they aren't signed in, it will be caught. They will have to sign in and they will go to the main page
        let ref = Database.database().reference()
        ref.child("purchases").child(purchaseCode).observeSingleEvent(of: .value, with: { snapshot in
            // Get users from purchase so we can update all entries
            do {
                let purchase = try snapshot.decode(Purchase.self)
                let childUpdates = ["/purchases/\(purchaseCode)/sharedTo/\(Auth.auth().currentUser!.uid)/": User(name: UIDevice.current.name, phone: nil, isAdmin: false),
                                    "/userPurchases/\(Auth.auth().currentUser!.uid)/\(purchaseCode)/" : purchase] as [String : Any]
                
                purchaseView.purchase = purchase
                
                controllers.append(loginView)
                controllers.append(purchaseTable)
                controllers.append(purchaseView)
                print(controllers)
                navController.setViewControllers(controllers, animated: true)
                //TODO do we want to keep track of this?
//                ref.updateChildValues(childUpdates)
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        return true
    }
}

