//
//  StackedElementViewController.swift
//  StackViewMenuAnimation
//
//  Created by Prateek Sharma on 02/01/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class StackedElementViewController: UIViewController {

    @IBOutlet weak var controllerName: UILabel!
    @IBOutlet weak var controllerDetail: UITextView!
    
    var headerString : String! {
        didSet {
            controllerName.text = headerString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
