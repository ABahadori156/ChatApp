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

class ChatVC: JSQMessagesViewController {
    
    //An Array that contains all the messages in the chat group
    var messages = [JSQMessage]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "xsagakenx"
        // Do any additional setup after loading the view.
    }

    
    
    //SEND MESSAGE BUTTON
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("didPressSendButton")
        print("\(text)")
        print(senderId)
        print(senderDisplayName)
        
        
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        
        //Here we let the collectionView know we sent a message so it updates on the UI
        collectionView.reloadData()
        print(messages)
    }
    
    
    
    //MESSAGE TAPPED FUNCTION FOR PLAYING VIDEOS
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("Message Bubble was tapped at Index Path: \(indexPath.item)")
        
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
        print("Did press Accessory Button")
        
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
        print("Type of Media: \(type)")
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
        print("Message Count: \(messages.count)")
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














