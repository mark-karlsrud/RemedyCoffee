//
//  MessageComposer.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 4/28/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import MessageUI

let textMessageRecipients = ["4803758592"]

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    var qrImage: UIImage
    
    init(qrImage: UIImage) {
        self.qrImage = qrImage
    }
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = "I got you a cup of coffee!"
        messageComposeVC.addAttachmentData(UIImagePNGRepresentation(qrImage)!, typeIdentifier: "qrcode", filename: "qrcode")
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
