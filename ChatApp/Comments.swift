//
//  Comments.swift
//  ChatApp
//
//  Created by Pasha Bahadori on 9/22/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import Foundation


/*
 ChatVC
 --------
 override func viewDidLoad() {
 super.viewDidLoad()
 self.senderId = "1"
 self.senderDisplayName = "xsagakenx"
 
 let rootRef = FIRDatabase.database().reference()    //Returns a reference to the root of our app
 
 //Storage in Firebase for all our messages - In this child location, we'll store all messages sent by all users in the app
 let messageRef = rootRef.child("messages")
 
 
 
 //UPLOAD DATA TO FIREBASE DATABASE
 //Generates unique ID per message so the database differentiates between messages
 //Each message as now at a child location of the messages reference with a unique ID
 messageRef.childByAutoId().setValue("First message")
 messageRef.childByAutoId().setValue("Second message")
 
 
 
 
 
 //RETRIEVING DATA FROM FIREBASE DATABASE
 //To look for data, we need to look at the collection of all messages that the message referenced
 //And we have to observe any event that occurs at this location - Events can be like when a child location is added, removed, changed
 //This data is retrieved anytime an event occurs
 
 //For pulling a new message, we should pull the new child that is added to the message location (FIRDataEventType.childAdded)
 //Due to the .childAdded event, each message will be printed 1 by 1, and the snapshot value is not a dictionary anymore
 messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
 print("Snapshot at messages: \(snapshot.value!)")
 //.value is 'optional AnyObject' because there can be no data in the database to observe sometimes, and there are different types of data so AnyObject is used
 //Now to extract the data information we want, we have to convert the Snapshot value to the type we expect
 //            if let dict = snapshot.value as? NSDictionary {
 //                print("Extracted data from Snapshot: \(dict)")
 //            }
 }
 
 
 print("Root Reference to FBDatabase: \(rootRef)")
 print("Reference to Message Storage in FBDatabase: \(messageRef)")
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 */
