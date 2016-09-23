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
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnon() {
        //Switch view by setting navigation controller as root view controller
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser, error) in
            if error == nil {
                print("UserId: \(anonymousUser!.uid)")
                
                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                newUser.setValue(["displayName" : "anonymous", "id" : "\(anonymousUser!.uid)", "profileUrl": ""])

                
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
                print(user?.photoURL)
                
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayName" : "\(user!.displayName!)", "id" : "\(user!.uid)", "profileUrl": "\(user!.photoURL!)"])
                
               self.switchToNavigationViewController()

            }
        })
    }
    
     func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        //Get the app delegate - we need it to get the root controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC

    }
    
}



