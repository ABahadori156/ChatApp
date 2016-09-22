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

class ChatVC: JSQMessagesViewController {
    
    //An Array that contains all the messages in the chat group
    var messages = [JSQMessage]()

    //Storage in Firebase for all our messages - In this child location, we'll store all messages sent by all users in the app
    let messageRef = FIRDatabase.database().reference().child("messages")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "xsagakenx"
        
   
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
        observeMessages()
    }

    //RETRIEVING MESSAGES FROM FIREBASE BY OBSERVING DATA
    func observeMessages() {
        
        //We look at the location of all messages in the database and observe events we're interested in
        //Here we're interested in if the new message data is pushed to the database - if yes, the observing function will return an FIRDataSnapshot object
        
        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            print(snapshot.value!)
            if let dict = snapshot.value as? [String: Any] {
            //We need to EXTRACT the dictionary values and encode them into a JSQMessage - So first we check if there is data being retrieved
            let mediaType = dict["MediaType"] as! String
            let senderId = dict["senderId"] as! String
            let senderName = dict["senderName"] as! String
            let text = dict["text"] as! String
            
            //ENCODING RETRIEVED MESSAGE DATA INTO JSQMESSAGE
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
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
        let messageData: Dictionary<String, Any> = ["text": text, "senderId": senderId, "senderName": senderDisplayName!, "MediaType": "TEXT"]
        //This data contains the message information sent by users such as input text, senderID, etc. It reflects how we store data in the database
        print(messageData)
        newMessage.setValue(messageData)
        
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
        return nil
    }
    
    
    //Configure the cell to display messages 
    //This displays a message bubble to display a message.
    //BUBBLE DISPLAY FOR MESSAGES
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        //We instantiate the bubble display first. This factory provides tools to create a JSQMessages bubble display object in the collectionView cells
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a view controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        
        //Get the app delegate - we need it to get the root controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Set the LogIn Controller as root view controller
        appDelegate.window?.rootViewController = loginVC
        self.dismiss(animated: true, completion: nil)
    }

  
    
 

}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    print("Did finish picking")
    //Get the image
    print("Image Info:\(info)")
    
    //This is the picture we chose from our photo library
    if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        let photo = JSQPhotoMediaItem(image: picture)
        
        //Then encode it into a mesage to present to the UI
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
    } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
        let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
    }
   
    self.dismiss(animated: true, completion: nil)
    collectionView.reloadData()
    }
}














