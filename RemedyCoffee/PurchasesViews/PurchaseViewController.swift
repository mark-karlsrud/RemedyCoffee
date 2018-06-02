//
//  PurchaseViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import Contacts

class PurchaseViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var purchaserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var redeemedLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    var purchase: Purchase?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.searchForContactUsingPhoneNumber(phoneNumber: "(480)313-1223)")
        addBackground(atLocation: "coffee_desk")
        purchaserLabel.text = purchase!.purchaser.user.name
        itemLabel.text = purchase!.item.item.description
        dateLabel.text = purchase!.date.toDate().toDateOnly()
        timeLabel.text = purchase!.date.toDate().toTimeOnly()
        amountLabel.text = purchase!.item.item.value.toCurrency()
        
        if ((purchase!.redeemed)!) {
            redeemedLabel.text = "Redeemed"
            redeemedLabel.textColor = #colorLiteral(red: 0.6133681536, green: 0, blue: 0, alpha: 1)
            
        } else {
            redeemedLabel.text = "Not Yet Redeemed"
            redeemedLabel.textColor = #colorLiteral(red: 0, green: 0.5714713931, blue: 0.1940918863, alpha: 1)
        }
        
        imgQRCode.image = createQRCodeImage(code: purchase!.code)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createQRCodeImage(code: String) -> UIImage? {
        let data = code.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            var qrImage : CIImage?
            if let colorFilter = CIFilter(name: "CIFalseColor") {
                colorFilter.setValue(filter.outputImage, forKey: "inputImage")
                colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0), forKey: "inputColor1") //Background white
                if let isRedeemed = purchase?.redeemed {
                    let alpha: CGFloat
                    if isRedeemed {
                        alpha = 0.3
                    } else {
                        alpha = 1
                    }
                    colorFilter.setValue(CIColor(red: 0.1137254902, green: 0.1058823529, blue: 0.1019607843, alpha: alpha) //Remedy Black
                        , forKey: "inputColor0")
                }
                qrImage = colorFilter.outputImage
            } else {
                qrImage = filter.outputImage
            }
            
            if let qrcodeImage = qrImage {
                let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
                let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
                
                let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                let context: CIContext = CIContext.init(options: nil)
                let cgImage: CGImage = context.createCGImage(transformedImage, from: transformedImage.extent)!
                let image: UIImage = UIImage.init(cgImage: cgImage)
                
                return image
            }
        }
        return nil
    }
    @IBAction func didClickSendToFriend(_ sender: Any) {
        // Make sure the device can send text messages
        if (self.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            // Note that the dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            errorAlert.addAction(okButton)
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
//        messageComposeVC.recipients = [purchase!.to.user.phone] as? [String]
        messageComposeVC.body = "I got you a \(purchase!.item.item.description!.lowercased())! Redeem at Remedy Coffee. Open in app: remedycoffee://\(purchase!.item.id)"
        if let data = UIImagePNGRepresentation(imgQRCode.image!) {
            messageComposeVC.addAttachmentData(data, typeIdentifier: "png", filename: "\(String(describing: purchase!.code.description)).png")
        }
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
