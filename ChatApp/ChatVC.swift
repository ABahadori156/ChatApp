//
//  ChatVC.swift
//  ChatApp
//
//  Created by Pasha Bahadori on 9/21/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth



class ChatVC: JSQMessagesViewController {
    
    //An Array that contains all the messages in the chat group
    var messages = [JSQMessage]()

    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    //Storage in Firebase for all our messages - In this child location, we'll store all messages sent by all users in the app
    let messageRef = FIRDatabase.database().reference().child("messages")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DIFFERENTIATING MESSAGES BETWEEN CURRENTUSER AND ELSE - So currentUser's message bubble is on the right, and other is on the left
        let currentUser = FIRAuth.auth()?.currentUser
        
        if currentUser?.isAnonymous == true {
             self.senderDisplayName = "Anonymous"
        } else {
            self.senderDisplayName = "\(currentUser?.displayName!)"
        }
        
        self.senderId = currentUser!.uid
        
        // observeUsers()
        observeMessages()
        
   
        //UPLOAD DATA TO FIREBASE DATABASE
        // messageRef.childByAutoId().setValue("First message")
        // messageRef.childByAutoId().setValue("Second message")
        

        //RETRIEVING DATA FROM FIREBASE DATABASE

//        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
//            //We're trying to show the child added event will be fired twice
//            //THe child-added event will be triggered TWICE for these two existed messages
//            if let dict = snapshot.value as? String {
//                print("Extracted data from Snapshot: \(dict)")
//            }
//        }
        
        //We call the observeMessages in viewDidLoad because we want to load the messages when we load the chatView
        
    }

    func observeUsers(id: String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value) { (snapshot: FIRDataSnapshot) in
            print(snapshot.value)
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(url: avatarUrl, messageId: id)
            }
            
            
        }
    }
    
    func setupAvatar(url: String, messageId: String) {
        if url != "" {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOf: fileUrl! as URL)
            let image = UIImage(data: data! as Data)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDict[messageId] = userImg
        } else {
            avatarDict[messageId] =  JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView.reloadData()
    }
    
    
    
    //RETRIEVING MESSAGES FROM FIREBASE BY OBSERVING DATA
    func observeMessages() {
        
        //We look at the location of all messages in the database and observe events we're interested in
        //Here we're interested in if the new message data is pushed to the database - if yes, the observing function will return an FIRDataSnapshot object
        
        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            // print(snapshot.value!)
            if let dict = snapshot.value as? [String: Any] {
            //We need to EXTRACT the dictionary values and encode them into a JSQMessage - So first we check if there is data being retrieved
            let mediaType = dict["MediaType"] as! String
            let senderId = dict["senderId"] as! String
            let senderName = dict["senderName"] as! String
                
                self.observeUsers(id: senderId)
                
                switch mediaType {
                    case "TEXT":
                    //ENCODING RETRIEVED MESSAGE DATA INTO JSQMESSAGE
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                    case "PHOTO":
                        let fileUrl = dict["fileUrl"] as! String
                        let url = NSURL(string: fileUrl)
                        let data = NSData(contentsOf: url! as URL)
                        let picture = UIImage(data: data! as Data)
                        let photo = JSQPhotoMediaItem(image: picture)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                        if self.senderId == senderId {
                              photo?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            photo?.appliesMediaViewMaskAsOutgoing = true
                    }
                    
                    
                    case "VIDEO":
                        let fileUrl = dict["fileUrl"] as! String
                        let video = NSURL(string: fileUrl)
                        let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                        if self.senderId == senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                            }
                default:
                    print("unknown data type")
                }
                
                
                self.collectionView.reloadData()
                
                //NEVER SAVE JSQ Formated messages to Firebase
        }
    }
}
    
    
    
    //We send a message to Firebase, then retrieve the message when the user sends a message
    
    //SEND MESSAGE BUTTON - We'll upload messages to Firebase when message button tapped, then we'll pull each new message from Firebase, append it to the message array, then display the message to the chat view
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        
//        //Here we let the collectionView know we sent a message so it updates on the UI
//        collectionView.reloadData()
        
        //Our plan is to push new message data to this child location, so at this new message location,
        let newMessage = messageRef.childByAutoId()
        
        //This is the format we want to structure our data and save it to Firebase so we pull and use it for JSQ later
        let messageData: Dictionary <String, Any> = ["text": text, "senderId": senderId, "senderName": senderDisplayName!, "MediaType": "TEXT"]
        //This data contains the message information sent by users such as input text, senderID, etc. It reflects how we store data in the database
        newMessage.setValue(messageData)
        
        //Clears textfield after sending a message
        self.finishSendingMessage()
    }
    
    
    
    //MESSAGE TAPPED FUNCTION FOR PLAYING VIDEOS
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        //Check if the message is a video or not
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                  self.present(playerViewController, animated: true, completion: nil)

            }
        }
    }
    
    
    //ATTACHMENT BUTTON
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
        //Lets them choose photos from photo library
            //let imagePicker = UIImagePickerController()
        
        //The ChatVC declared it would implement protocol UIImagePickerControllerDelegate so that it can access the media info the file image picked, but the UIImagePickerController doesn't know that the ChatVC did that. So the ChatVC must be a delegate of the UIImagePickerController
        //So in the ChatVC we need to set it as a delegate of the image picker because this is inside the class definition
            // imagePicker.delegate = self
        
            // self.present(imagePicker, animated: true, completion: nil)
    }
    
    //VIDEO AND IMAGE LIBRARY
    func getMediaFrom(type: CFString) {
        let mediaPicker = UIImagePickerController()
    
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    
    //MESSAGE FEED
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        //Here we return the JSQMessage at the indexPath to feed it into the collection view. 
        //The collectionView has message data to display
        return messages[indexPath.item]
    }
    
    //AVATAR IMAGE CONFIG
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        //The avatar image should depend on the user type, so we get the avatar from the avatar dictionary we created
        return avatarDict[message.senderId]
       
    }
    
    
    //Configure the cell to display messages 
    //This displays a message bubble to display a message.
    //BUBBLE DISPLAY FOR MESSAGES
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            //We instantiate the bubble display first. This factory provides tools to create a JSQMessages bubble display object in the collectionView cells
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
            
        } else {
            //We instantiate the bubble display first. This factory provides tools to create a JSQMessages bubble display object in the collectionView cells
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue)
        }
        
       
    }
    
    //MESSAGE COUNT
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
  
    //MESSAGE CELLS
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    
    
    @IBAction func logoutDidTapped(_ sender: UIBarButtonItem) {
        print("User Auth Status: \(FIRAuth.auth()?.currentUser)")
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        print(FIRAuth.auth()?.currentUser)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a view controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        
        //Get the app delegate - we need it to get the root controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the LogIn Controller as root view controller
        appDelegate.window?.rootViewController = loginVC
        self.dismiss(animated: true, completion: nil)
    }

    
    
    
    //SAVING IMAGES/VIDEOS TO FIREBASE STORAGE - Also push media message data to the data base too
    func sendMedia(picture: UIImage?, video: NSURL?) {
        print("Pushing to Storage: \(picture)")
        
        //Reference to location of our Firebase Storage where we will be pushing our media files too
        print(FIRStorage.storage().reference())
        
        if let picture = picture {
            //File Path to the storage
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            //FIRStorageMetaData gives extra data
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                //Since we have one URL, the index should be 0
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                
                //This is the format we want to structure our data and save it to Firebase so we pull and use it for JSQ later
                let messageData: Dictionary <String, Any> = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                //This data contains the message information sent by users such as input text, senderID, etc. It reflects how we store data in the database
                print(messageData)
                newMessage.setValue(messageData)
                
                
                print("Here is the Metadata: \(metadata)")
            }
            
            //We can group messages by users
            
            
            //ORGANIZING FOLDERS ON YOUR COMP - You name the file path
        } else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            //FIRStorageMetaData gives extra data
            FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                //Since we have one URL, the index should be 0
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                
                //This is the format we want to structure our data and save it to Firebase so we pull and use it for JSQ later
                let messageData: Dictionary <String, Any> = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                //This data contains the message information sent by users such as input text, senderID, etc. It reflects how we store data in the database
                print(messageData)
                newMessage.setValue(messageData)
            }
        }
        
    }
        
      
 
    
}

//PHOTO AND VIDEO
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    print("Did finish picking")
    //Get the image
    print("Image Info:\(info)")
    
    //This is the picture we chose from our photo library
    if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
        //If the user picks a photo, we'll push the chosen picture to the storage because we make it clear that users can choose EITHER photo or video by the if-else statement here
        sendMedia(picture: picture, video: nil)
    } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {

        //PUSHING VIDEO TO STORAGE
        sendMedia(picture: nil, video: video)
    }
   
    self.dismiss(animated: true, completion: nil)
    collectionView.reloadData()
    }
}














