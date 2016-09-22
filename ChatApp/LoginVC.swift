//
//  LoginVC.swift
//  ChatApp
//
//  Created by Pasha Bahadori on 9/21/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the border color and width
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        
        GIDSignIn.sharedInstance().clientID = "1060754309612-1ujjabaf49nno1300ne2hv7gi6j0mav4.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    @IBAction func loginAnonDidTapped(_ sender: UIButton) {
        //Switch view by setting navigation controller as root view controller
        Helper.helper.loginAnon()
            }
 
    @IBAction func googleLoginDidTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
     
        
       

        print("Login through Google was tapped")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.logInWithGoogle(authentications: user.authentication)
    }
    

}
