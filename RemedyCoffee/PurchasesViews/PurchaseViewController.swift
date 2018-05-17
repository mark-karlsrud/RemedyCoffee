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

class PurchaseViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var redeemedLabel: UILabel!
    
    var purchase: Purchase?
    var qrCode: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackground(atLocation: "coffee_desk")
        
        toLabel.text = purchase?.to.user.name
        fromLabel.text = purchase?.from.user.name
        dateLabel.text = purchase?.date.toDate().toDateOnly()
        timeLabel.text = purchase?.date.toDate().toTimeOnly()
        amountLabel.text = purchase?.item.item.value.toCurrency()
        
        if ((purchase?.redeemed)!) {
            redeemedLabel.text = "Redeemed"
            redeemedLabel.textColor = #colorLiteral(red: 0.6133681536, green: 0, blue: 0, alpha: 1)
            
        } else {
            redeemedLabel.text = "Not Yet Redeemed"
            redeemedLabel.textColor = #colorLiteral(red: 0, green: 0.5714713931, blue: 0.1940918863, alpha: 1)
        }
        
        let data = purchase?.code.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        displayQRCodeImage(qrcodeImage: (filter?.outputImage)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func displayQRCodeImage(qrcodeImage: CIImage) {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(transformedImage, from: transformedImage.extent)!
        let image: UIImage = UIImage.init(cgImage: cgImage)
        
//        qrCode = UIImage(ciImage: transformedImage)
        
        imgQRCode.image = image
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
        messageComposeVC.recipients = [purchase?.to.user.phone?.description] as? [String]
        messageComposeVC.body = "I got you a cup of coffee! Redeem at Remedy Coffee"
        if let data = UIImagePNGRepresentation(imgQRCode.image!) {
            messageComposeVC.addAttachmentData(data, typeIdentifier: "png", filename: "\(String(describing: purchase?.code.description)).png")
        }
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
