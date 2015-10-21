//
//  detailView.swift
//  TalkItUp
//
//  Created by Peter Zimmerman on 9/21/15.
//  Copyright © 2015 Peter Zimmerman. All rights reserved.
//

import UIKit
import MessageUI

class detailView: UIViewController {
    static var name =  String()
    static var phone = String()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        phoneLabel.text = phone
//        nameLabel.text = name
    }
}