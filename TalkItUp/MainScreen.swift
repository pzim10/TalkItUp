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

class MainScreen: UIViewController, CNContactViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var imageArray = NSMutableArray()
    var imageTimer = NSTimer()
    var contacts = [CNContact]()
    var i = 1
    var j = 0
    @IBOutlet weak var reconnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.contacts = self.findContacts()
        }
    }
    
    // gather the phone's contact information
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
    
    // Button press, starts animation
    @IBAction func reconnect(sender: AnyObject) {
        reconnectButton.hidden = true
        j = 0
        for images in imageArray {
            images.removeFromSuperview()
        }
        imageArray.removeAllObjects()
        imageTimer = NSTimer .scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("movingImage"), userInfo: nil, repeats: true)
    }
    
    // image animation
    func movingImage() {
        if i == 5 { i = 1 }
        if j == 50 { // defines the length of the animation
            imageTimer.invalidate()
            j = 0
            
            _ = NSTimer .scheduledTimerWithTimeInterval(2.3, target: self, selector: Selector("imageCleanup"), userInfo: nil, repeats: false)
        }
        
        let movingImage = UIImageView(frame:CGRectMake(100, 150, 200, 200))
        movingImage.image = UIImage(named: "\(i)")
        
        self.view .addSubview(movingImage)
        let rect = CGRectMake(-350, 0, 700, 200)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.additive = true
        animation.path = CGPathCreateWithEllipseInRect(rect, nil)
        animation.calculationMode = kCAAnimationPaced
        animation.duration = 3
        animation.repeatCount = 1.0
        
        movingImage.layer .addAnimation(animation, forKey: "position")
        
        imageArray .addObject(movingImage)
        i++
        j++
    }
    
    // cleanup the view
    func imageCleanup() {
        let random = arc4random_uniform(UInt32(imageArray.count))
        for images in imageArray {
            print("\(random)")
            if j != Int(random) {
                images.removeFromSuperview()
            }
            j++
        }
        sendText(Int(random))
    }
    
    func sendText(randomNumber: Int) {
        // get random contact
        var phoneNumberString =  String()
        let contact = contacts[randomNumber]
        var stringArray = [String]()
        for number in contact.phoneNumbers {
            let phoneNumber = number.value as! CNPhoneNumber
            stringArray.append(phoneNumber.stringValue)
        }
        phoneNumberString = stringArray[0]
        
        // Fill in text draft
        let message = MFMessageComposeViewController()
        message.recipients = [phoneNumberString]
        message.body = "Did it work?"
        message.messageComposeDelegate = self
        
        // open text draft
        self.presentViewController(message, animated: true, completion: nil)
        self .messageComposeViewController(message, didFinishWithResult: MessageComposeResultSent)
    }
    
    // open text draft to contact, deal with conditions, also part of delegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if result == MessageComposeResultCancelled {
            print("Cancelled")
        } else if result == MessageComposeResultFailed {
            print("Failed")
        } else if result == MessageComposeResultSent {
            print("Sent")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}