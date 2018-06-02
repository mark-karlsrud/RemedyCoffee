//
//  PurchaserViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/12/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import PassKit

class ItemViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var applePayView: UIView!
    
    static let supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    var ref: DatabaseReference!
    var item: ItemWrapper?
//    var purchase: Purchase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(atLocation: "wood_background")
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ItemViewController.supportedNetworks) {
            let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
            button.addTarget(self, action: #selector(applePayButtonPressed(_:)), for: .touchUpInside)
            button.center = applePayView.convert(applePayView.center, from: applePayView.superview)
            button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
            applePayView.addSubview(button)
        }
        
        self.ref = Database.database().reference()
        descriptionLabel.text = item?.item.description
        if let price = item?.item.value {
            valueLabel.text = "$\(price)"
        }
        if let size = item?.item.size {
            sizeLabel.text = "Size: \(size)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applePayButtonPressed(_ sender: Any) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.remedycoffee.ios"
        request.supportedNetworks = ItemViewController.supportedNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        let price : NSDecimalNumber = NSDecimalNumber(string: item?.item.value.description)
        request.paymentSummaryItems = [            
            PKPaymentSummaryItem(label: (item?.item.description)!, amount: price),
            PKPaymentSummaryItem(label: "Remedy Coffee", amount: price)
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        self.present(applePayController!, animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        let fromUser = User(name: "?", phone: nil, isAdmin: false)
        let purchaser = UserWrapper(id: Auth.auth().currentUser!.uid, user: fromUser)
        let purchaseCode = UUID().uuidString
        let redeemed = false
        let date = Date().toDateAndTime()
        let purchase = Purchase(purchaser: purchaser, item: item, code: purchaseCode, redeemed: redeemed, date: date, sharedTo: [Auth.auth().currentUser!.uid: fromUser])
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(purchase).toDict()
            let childUpdates = ["/purchases/\(purchaseCode)/": json,
                                "/userPurchases/\(String(describing: purchase.purchaser.id!))/\(purchaseCode)/" : json]
            self.ref.updateChildValues(childUpdates)
            completion(PKPaymentAuthorizationStatus.success)
            goToPurchaseView(purchase)
        } catch let error {
            print(error)
            completion(PKPaymentAuthorizationStatus.failure)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func goToPurchaseView(_ purchase: Purchase) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseView = storyboard.instantiateViewController(withIdentifier: "PurchaseView") as! PurchaseViewController
        purchaseView.purchase = purchase
        
        var controllers = self.navigationController?.viewControllers
        print(controllers!)
        //TODO
//        controllers?.removeLast()
//        controllers?.removeLast()
//        controllers?.append(storyboard.instantiateViewController(withIdentifier: "PurchasesTable") as! PurchasesTableController)
//        controllers?.append(purchaseView)
        self.navigationController?.setViewControllers(controllers!, animated: true)
    }
}
