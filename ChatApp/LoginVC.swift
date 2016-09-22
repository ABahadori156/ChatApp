//
//  LoginVC.swift
//  ChatApp
//
//  Created by Pasha Bahadori on 9/21/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the border color and width
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
    }

    @IBAction func loginAnonDidTapped(_ sender: UIButton) {
        print("Login anonymously was tapped")
    }
 
    @IBAction func googleLoginDidTapped(_ sender: UIButton) {
        print("Login through Google was tapped")
    }
    
    

}
