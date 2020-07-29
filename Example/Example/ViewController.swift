//
//  ViewController.swift
//  Example
//
//  Created by Alexy Ibrahim on 7/29/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import AIEnvironmentKit

class ViewController: UIViewController {

    @IBOutlet var label_Environment:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let env: String = AIEnvironmentKit.environmentName
        self.label_Environment.text = env
        
        AIEnvironmentKit.executeIfNotAppStore {
            print("not app store")
        }
        
    }


}

