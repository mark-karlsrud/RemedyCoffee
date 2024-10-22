//
//  PurchaserViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/12/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import PassKit

let MERCHANT_ID = "merchant.com.remedycoffee.ios"
let CLIENT_KEY = "NEED TO GET THIS"

class ItemViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var applePayView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    static let supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    var ref: DatabaseReference!
    var item: ItemWrapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(atLocation: "wood_background")
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ItemViewController.supportedNetworks) && Worldpay.sharedInstance().canMakePayments() {
            let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
            button.addTarget(self, action: #selector(applePayButtonTapped(sender:)), for: .touchUpInside)
            button.center = applePayView.convert(applePayView.center, from: applePayView.superview)
            button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
            applePayView.addSubview(button)
            
            //Load WorldPay
            let wp: Worldpay = Worldpay.sharedInstance();
            wp.clientKey = CLIENT_KEY; //TODO!
            wp.reusable = true;
            wp.validationType = WorldpayValidationTypeAdvanced;
        }
        
        self.ref = Database.database().reference()
        descriptionLabel.text = item?.item.description
        if let price = item?.item.value {
            valueLabel.text = price.toCurrency()
        }
        if let size = item?.item.size {
            sizeLabel.text = "Size: \(size)"
        } else {
            sizeLabel.text = ""
        }
        
        if let imageName = item?.item.imageName {
            let reference = Storage.storage().reference().child("images/menu/\(imageName)")
            reference.getData(maxSize: 1 * Int64(self.image.frame.width) * Int64(self.image.frame.height)) { data, error in
                self.image.image = UIImage(data: data!)
            }
        } else {
            self.image.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func applePayButtonTapped(sender: UIButton) {
        if let request = Worldpay.sharedInstance().createPaymentRequest(withMerchantIdentifier: MERCHANT_ID) {
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
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        Worldpay.sharedInstance().createToken(withPaymentData: payment.token.paymentData, success: { (code, responseDict) in
            //Handle the Worldpay token here. At this point you should connect to your own server and complete the purchase from there.
            //Let's just add the token to our db
            let fromUser = User(name: "?", phone: nil, isAdmin: false)
            let purchaser = UserWrapper(id: Auth.auth().currentUser!.uid, user: fromUser)
            let purchaseCode = UUID().uuidString
            let redeemed = false
            let date = Date().toDateAndTime()
            let purchase = Purchase(purchaser: purchaser, item: self.item, code: purchaseCode, redeemed: redeemed, date: date, sharedTo: [Auth.auth().currentUser!.uid: fromUser], token: code)
            
            let encoder = JSONEncoder()
            do {
                let json = try encoder.encode(purchase).toDict()
                let childUpdates = ["/purchases/\(purchaseCode)/": json,
                                    "/userPurchases/\(String(describing: purchase.purchaser.id!))/\(purchaseCode)/" : json]
                self.ref.updateChildValues(childUpdates) { (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print(error)
                        completion(PKPaymentAuthorizationStatus.failure)
                    } else {
                        completion(PKPaymentAuthorizationStatus.success)
                        self.goToPurchaseView(purchase)
                    }
                }
            } catch let error {
                print(error)
                completion(PKPaymentAuthorizationStatus.failure)
            }
        }) { (responseDict, errors) in
            print(errors)
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
//        print(controllers!)
        if controllers?.last is ItemViewController {
            controllers?.removeLast()
        }
        if controllers?.last is MenuTableController {
            controllers?.removeLast()
        }
        controllers?.append(storyboard.instantiateViewController(withIdentifier: "PurchasesTable") as! PurchasesTableController)
        controllers?.append(purchaseView)
        self.navigationController?.setViewControllers(controllers!, animated: true)
    }
}
