//
//  Helper.swift
//  ChatApp
//
//  Created by Pasha Bahadori on 9/21/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class Helper {
    static let helper = Helper()
    
    func loginAnon() {
        //Switch view by setting navigation controller as root view controller
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error == nil {
                print("UserId: \(user!.uid)")
               self.switchToNavigationViewController()
            } else {
                print("error!.localizedDescription")
                return
            }
        })
    }

    
    func logInWithGoogle(authentications: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentications.idToken, accessToken: authentications.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email)
                print(user?.displayName)
                
               self.switchToNavigationViewController()

            }
        })
    }
    
    private func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        //Get the app delegate - we need it to get the root controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC

    }
    
}



