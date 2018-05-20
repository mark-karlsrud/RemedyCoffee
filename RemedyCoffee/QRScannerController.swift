//
//  QRScannerController.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 3/14/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QRScannerController: UIViewController {
    var ref: DatabaseReference!
    
//    @IBOutlet var messageLabel:UILabel!
//    @IBOutlet var topbar: UIView!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let input: AVCaptureDeviceInput
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            // Set the input device on the capture session.
            self.captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.view.layer.bounds
        self.view.layer.addSublayer(self.videoPreviewLayer!)
        
        // Start video capture.
        self.captureSession.startRunning()
        
        // Move the message label and top bar to the front
//        self.view.bringSubview(toFront: self.messageLabel)
//        self.view.bringSubview(toFront: self.topbar)
        
        // Initialize QR Code Frame to highlight the QR code
        self.qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = self.qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = #colorLiteral(red: 0, green: 0.5714713931, blue: 0.1940918863, alpha: 1)
            qrCodeFrameView.layer.borderWidth = 2
            self.view.addSubview(qrCodeFrameView)
            self.view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func readQRCode(decodedStr: String) {
        
        if presentedViewController != nil {
            return
        }
        
        //TODO add logic to make sure decodedStr is in the correct form (coupon UUID)
        
        let alertPrompt = UIAlertController(title: "Coffee Coupon", message: "Mark coupon \(decodedStr) as redeemed? ", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("Redeemed coupon \(decodedStr)")
            self.redeemCoupon(purchaseCode: decodedStr)
            self.captureSession.stopRunning()
            self.navigationController?.popViewController(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func redeemCoupon(purchaseCode: String) {
        //fetch first
        ref.child("purchases").child(purchaseCode).observeSingleEvent(of: .value, with: { snapshot in
            // Get users from purchase so we can update all entries
            do {
                let purchase = try snapshot.decode(Purchase.self)
                var childUpdates = ["/purchases/\(purchaseCode)/redeemed/": true,
                                    "/userPurchases/\(purchase.purchaser.id!)/\(purchaseCode)/redeemed/" : true]
                //Update redeemed value for everyone that the item was shared with
                //TODO do we want to keep track of this?
//                for (id, _) in purchase.sharedTo {
//                    childUpdates["/userPurchases/\(id)/\(purchaseCode)/redeemed/"] = true
//                }
                
                self.ref.updateChildValues(childUpdates)
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                readQRCode(decodedStr: metadataObj.stringValue!)
//                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}
