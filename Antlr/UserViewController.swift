//
//  UserViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/26/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import Photos




class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var profilePicture: UIImage?
    var uid: String?
    let imagePicker = UIImagePickerController()
   var storageRef:FIRStorageReference!
    var user = UserInfoViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate =  self
        storageRef = FIRStorage.storage().referenceForURL("gs://project-4762449512525788408.appspot.com")
        // start Auth
       FIRAuth.auth()?.addAuthStateDidChangeListener{ auth, user in
            if let user = user {
                // Create a reference to the file you want to download
                let islandRef = self.storageRef.child("\(user.uid).jpeg")
                print("\(user.uid).jpeg")
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                islandRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        self.profilePicture = UIImage(data: data!)
                        self.imageView.image = self.profilePicture
                        
                    }
                }
                // User is signed in.
            } else {
                // No user is signed in.
            }
        }// end of sign in 
        
        

        
    
    } // viewDidLoad end

    
    
    @IBAction func insertImage(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    } // insert image end

    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("finished picking")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFill
            print("changing the image")
            profilePicture = pickedImage
            
            imageView.image = profilePicture
            
            let imageData = UIImageJPEGRepresentation(pickedImage, 1.0)
            // Data in memory
            if imageData != nil {
                print("got an image to save")
                let data: NSData = imageData!
                
                // Create a reference to the file you want to upload
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                let riversRef = self.storageRef.child("\(self.uid).jpeg")
                // Upload the file to the path "images/rivers.jpg"
                _ = riversRef.putData(data, metadata: nil) { metadata, error in
                    if (error != nil) {
                        print("done goofed")
                        
                        // Uh-oh, an error occurred!
                    } else {
                        print("upload complete")
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        _ = metadata!.downloadURL
                    }
                }
                
            } // end of upload
            
        } // end of picked image
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func changeUID(id: String){
        print("about to change id to..." + id)
        self.uid = id
        print("new id is.. " + self.uid!)
        
    }
    
    func updateImage(image: UIImage){
        print("changing the image now...")
        imageView.image = image
        
    }
    
    
} // end of class

