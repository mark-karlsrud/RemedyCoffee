//
//  PurchaseViewController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/1/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import Firebase

class PurchaseViewController: UIViewController {
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var redeemedLabel: UILabel!
    
    var purchase: Purchase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toLabel.text = purchase?.to.user.name
        fromLabel.text = purchase?.from.user.name
        dateLabel.text = purchase?.date
        amountLabel.text = purchase?.item.item.value.toCurrency()
        
        if ((purchase?.redeemed)!) {
            redeemedLabel.text = "Redeemed"
            redeemedLabel.textColor = UIColor.red
            
        } else {
            redeemedLabel.text = "Not Yet Redeemed"
            redeemedLabel.textColor = UIColor.green
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
    
    
    func displayQRCodeImage(qrcodeImage: CIImage) {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
}
