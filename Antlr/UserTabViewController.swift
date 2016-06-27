//
//  UserTabViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/27/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UserTabViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    // picture and firebase setup
    let imagePicker = UIImagePickerController()
    var storageRef:FIRStorageReference!
    let ref = FIRDatabase.database().reference()
    
    
    // variable initializers

    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        updateData()

        loading.startAnimating()
        imagePicker.delegate =  self
        storageRef = FIRStorage.storage().referenceForURL("gs://project-4762449512525788408.appspot.com")
        
    } // end of ViewDidLoad
    
    func oldPhoto (path: String) {
        print("about to load oldPhoto")

        //Create a reference to the file you want to download
        
        print("this is the info....\(path)")
        let imageRef = storageRef.child("\(path).jpeg")
        print(path)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print("no profile image here")
                self.changePhoto(1)
                self.loading.stopAnimating()
                // Uh-oh, an error occurred!
            } else {

                self.loading.stopAnimating()
                print("bueno")
                let profileImage = UIImage(data: data!)
                self.imageView.image = profileImage!
                
            } // success download
        }
        
    } // end of old photo
    
    @IBAction func changePhoto(sender: AnyObject) {
        print("about to add new photo")
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
         
            imageView.image = pickedImage
            
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.8)
            // Data in memory
            if imageData != nil {
                print("got an image to save")
                let data: NSData = imageData!
                
                // Create a reference to the file you want to upload
                
                
                
                print("step 7")
                let userID = FIRAuth.auth()?.currentUser?.uid
                ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get user value
                    print("step 8")
                    
                    UserInfoViewController.AntlrUser.uid = snapshot.value!["uid"] as? String
                    UserInfoViewController.AntlrUser.gender = snapshot.value!["gender"] as? String
                    UserInfoViewController.AntlrUser.wantRate = snapshot.value!["wantRate"] as? String
                    UserInfoViewController.AntlrUser.group = snapshot.value!["group"] as? String
                    print("finished fetching data")
                    
                    let path = "\(UserInfoViewController.AntlrUser.wantRate!)/\(UserInfoViewController.AntlrUser.gender!)/\(UserInfoViewController.AntlrUser.group!)/"
                    let path2 = "\(UserInfoViewController.AntlrUser.wantRate!)/EVERYONE/\(UserInfoViewController.AntlrUser.group!)/"
                    
                    
                    
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    let imageRef = self.storageRef.child("\(path)\(userID!).jpeg")
                    let everyoneRef = self.storageRef.child("\(path2)\(userID!).jpeg")
                    
                    
                    print("upload beginning")
                    
                    
                    
                    
                    // Upload the file to the path "images/rivers.jpg"
                    _ = imageRef.putData(data, metadata: nil) { metadata, error in
                        if (error != nil) {
                            print("done goofed")
                            
                            // Uh-oh, an error occurred!
                        } else {
                            print("upload complete")
                            // Upload the file to the path "images/rivers.jpg"
                            _ = everyoneRef.putData(data, metadata: nil) { metadata, error in
                                if (error != nil) {
                                    print("done goofed 2 ")
                                    
                                    // Uh-oh, an error occurred!
                                } else {
                                    print("upload 2 complete")
                                    
                                    // Metadata contains file metadata such as size, content-type, and download URL.
                                    _ = metadata!.downloadURL
                                }
                            } // end of location
                            
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            _ = metadata!.downloadURL
                        }
                    } // end of location
      
                    // ...
                }) { (error) in
                    print("found the error")
                    print(error.localizedDescription)
                }
            } // end of upload
            
            
            
            
        } // end of picked image
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    } // end of dismiss
    
    func updateData(){
        print("about to update")
        let userID = FIRAuth.auth()?.currentUser?.uid
        print("is this it?")
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            print("updating now")
            let updatedGender = snapshot.value!["gender"] as? String
            let updatedGroup = snapshot.value!["group"] as? String
            let updatedUid = snapshot.value!["uid"] as? String
            let updatedWantRate = snapshot.value!["wantRate"] as? String

            
            self.createPath(updatedUid, gender: updatedGender, group: updatedGroup, wantRate: updatedWantRate)
            
            
            // ... 
        }) { (error) in
            print(error.localizedDescription)
        }
    } // end of update
    
    func createPath(uid: String? , gender: String?, group: String?, wantRate: String?) {
        
        print("about tot make path")
      
        let path = "\(wantRate!)/\(gender!)/\(group!)/\(uid!)"
        print("this is the path...")
        print(path)
        
        oldPhoto(path)
        
    } // end of createPath
    
    @IBAction func signOut(sender: UIBarButtonItem) {
        try! FIRAuth.auth()!.signOut()
        performSegueWithIdentifier("signOut", sender: nil)
    }
    
    
    
    
    
    // test swipe

}
