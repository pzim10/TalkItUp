//
//  ViewController.swift
//  TalkItUp
//
//  Created by Peter Zimmerman on 9/12/15.
//  Copyright © 2015 Peter Zimmerman. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI

class ContactsViewController: UIViewController, CNContactViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var imageArray = NSMutableArray()
    var imageTimer = NSTimer()
    var contacts = [CNContact]()
    var i = 1
    var j = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.contacts = self.findContacts()
            self.contacts = self.checkContacts()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView!.reloadData()
            })
        }
    }

    func findContacts() -> [CNContact] {
        let store = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey, CNContactImageDataKey]
    
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
    
        var contacts = [CNContact]()
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return contacts
    }
    
    func checkContacts() -> [CNContact] {
        var i = 0
        for contact in contacts {
            var stringArray = [String]()
            for number in contact.phoneNumbers {
                let phoneNumber = number.value as! CNPhoneNumber
                stringArray.append(phoneNumber.stringValue)
                if stringArray.count > 0 {
                    break
                }
            }
            if stringArray.count == 0 {
                contacts.removeAtIndex(i)
                i--
            }
            i++
        }
        return contacts
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("contact")
        
        let contact = contacts[indexPath.row] as CNContact
        cell!.textLabel!.text = CNContactFormatter.stringFromContact(contact, style: .FullName)
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact = contacts[indexPath.row] as CNContact
        self.nameLabel.text = CNContactFormatter.stringFromContact(contact, style: .FullName)
        if contact.imageData != nil {
            image.image = UIImage(data: contact.imageData!)
        } else {
            image.image = nil
        }
        if let phoneNumberLabel = self.phoneLabel {
            var stringArray = [String]()
            for number in contact.phoneNumbers {
                let phoneNumber = number.value as! CNPhoneNumber
                stringArray.append(phoneNumber.stringValue)
            }
            phoneNumberLabel.text = stringArray[0]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}