//
//  PhoneContacts.swift
//  RemedyCoffee
//
//  Created by Mark Karlsrud on 5/7/18.
//  Copyright © 2018 Mark Karlsrud. All rights reserved.
//

import Foundation
import ContactsUI
import Contacts

class PhoneContacts {
    class func getContacts() -> [CNContact] {
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                contacts.append(contact)
            }
        } catch {
            print(error.localizedDescription)
        }
        return contacts
    }
}

/*
 
 
 // MARK: - App Logic
 func showMessage(message: String) {
 // Create an Alert
 let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
 
 // Add an OK button to dismiss
 let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
 }
 alertController.addAction(dismissAction)
 
 // Show the Alert
 self.present(alertController, animated: true, completion: nil)
 }
 
 func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
 // Get authorization
 let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
 
 // Find out what access level we have currently
 switch authorizationStatus {
 case .authorized:
 completionHandler(true)
 
 case .denied, .notDetermined:
 CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
 if access {
 completionHandler(access)
 }
 else {
 if authorizationStatus == CNAuthorizationStatus.denied {
 //                        DispatchQueue.async(DispatchQueue.main, execute: { () -> Void in
 let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
 self.showMessage(message: message)
 //                        })
 }
 }
 })
 
 default:
 completionHandler(false)
 }
 }
 
 //    @IBAction func findContactInfoForPhoneNumber(sender: UIButton) {
 //        self.searchForContactUsingPhoneNumber(phoneNumber: "(888)555-1212)")
 //    }
 
 func searchForContactUsingPhoneNumber(phoneNumber: String) {
 DispatchQueue.global(qos: .userInteractive).async {
 self.requestForAccess { (accessGranted) -> Void in
 if accessGranted {
 let keys = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
 var contacts = [CNContact]()
 var message: String!
 
 let contactsStore = CNContactStore()
 do {
 try contactsStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys)) {
 (contact, cursor) -> Void in
 if (!contact.phoneNumbers.isEmpty) {
 let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
 for phoneNumber in contact.phoneNumbers {
 let phoneNumberStruct = phoneNumber.value
 let phoneNumberString = phoneNumberStruct.stringValue
 let phoneNumberToCompare = phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
 if phoneNumberToCompare == phoneNumberToCompareAgainst {
 contacts.append(contact)
 }
 }
 }
 }
 
 if contacts.count == 0 {
 message = "No contacts were found matching the given phone number."
 }
 }
 catch {
 message = "Unable to fetch contacts."
 }
 
 if message != nil {
 DispatchQueue.main.async {
 self.showMessage(message: message)
 }
 }
 else {
 // Success
 DispatchQueue.main.async {
 // Do someting with the contacts in the main queue, for example
 /*
 self.delegate.didFetchContacts(contacts) <= which extracts the required info and puts it in a tableview
 */
 print(contacts) // Will print all contact info for each contact (multiple line is, for example, there are multiple phone numbers or email addresses)
 let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
 print(contact.givenName) // Print the "first" name
 print(contact.familyName) // Print the "last" name
 //                            if contact.isKeyAvailable(CNContactImageDataKey) {
 //                                if let contactImageData = contact.imageData {
 //                                    print(UIImage(data: contactImageData)) // Print the image set on the contact
 //                                }
 //                            } else {
 //                                // No Image available
 //
 //                            }
 }
 }
 }
 }
 }
 }
 */
