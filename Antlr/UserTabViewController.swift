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
import Crashlytics
import Fabric

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
        storageRef = FIRStorage.storage().reference(forURL: "gs://project-4762449512525788408.appspot.com")
        
    } // end of ViewDidLoad
    
    func oldPhoto (_ path: String) {
        print("about to load oldPhoto")

        //Create a reference to the file you want to download
        
        print("this is the info....\(path)")
        let imageRef = storageRef.child("\(path).jpeg")
        print(path)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 5 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print("no profile image here")
                self.changePhoto(1 as AnyObject)
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
    
    @IBAction func changePhoto(_ sender: AnyObject) {
        print("about to add new photo")
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    } // insert image end
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("finished picking")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            print("changing the image")
         
            imageView.image = pickedImage
            
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.8)
            // Data in memory
            if imageData != nil {
                print("got an image to save")
                let data: Data = imageData!
                
                // Create a reference to the file you want to upload
                
                
                
                print("step 7")
                let userID = FIRAuth.auth()?.currentUser?.uid
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print("step 8")
                    
                    UserInfoViewController.AntlrUser.uid = snapshot.value! as? String
                    UserInfoViewController.AntlrUser.gender = snapshot.value! as? String
                    UserInfoViewController.AntlrUser.wantRate = snapshot.value! as? String
                    UserInfoViewController.AntlrUser.group = snapshot.value! as? String
                    print("finished fetching data")
                    
                    let path = "\(UserInfoViewController.AntlrUser.wantRate!)/\(UserInfoViewController.AntlrUser.gender!)/\(UserInfoViewController.AntlrUser.group!)/uid/"
                    let path2 = "\(UserInfoViewController.AntlrUser.wantRate!)/EVERYONE/\(UserInfoViewController.AntlrUser.group!)/uid/"
                    
                    
                    
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    let imageRef = self.storageRef.child("\(path)\(userID!).jpeg")
                    let everyoneRef = self.storageRef.child("\(path2)\(userID!).jpeg")
                    
                    
                    print("upload beginning")
                    
                    
                    
                    
                    // Upload the file to the path "images/rivers.jpg"
                    _ = imageRef.put(data, metadata: nil) { metadata, error in
                        if (error != nil) {
                            print("done goofed")
                            
                            // Uh-oh, an error occurred!
                        } else {
                            print("upload complete")
                            // Upload the file to the path "images/rivers.jpg"
                            let uploadTask = everyoneRef.put(data, metadata: nil) { metadata, error in
                                if (error != nil) {
                                    print("done goofed 2 ")
                                    
                                    // Uh-oh, an error occurred!
                                } else {
                                    print("upload 2 complete")
                                    
                                    // Metadata contains file metadata such as size, content-type, and download URL.
                                    _ = metadata!.downloadURL
                                }
                                
                            } // end of location
                            
                            self.progressReport(uploadTask)
                            
                            
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            _ = metadata!.downloadURL
                        }
                    } // end of location

                }) { (error) in
                    print("found the error")
                    print(error.localizedDescription)
                }
                
            } // end of upload
            
        

        } // end of picked image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    } // end of dismiss
    
    func updateData(){
        print("about to update")
        let userID = FIRAuth.auth()?.currentUser?.uid
        print("is this it?")
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print("updating now")
            let updatedGender = snapshot.value! as? String
            let updatedGroup = snapshot.value! as? String
            let updatedUid = snapshot.value!  as? String
            let updatedWantRate = snapshot.value! as? String

            
            self.createPath(updatedUid, gender: updatedGender, group: updatedGroup, wantRate: updatedWantRate)
            
            
            // ... 
        }) { (error) in
            print(error.localizedDescription)
        }
    } // end of update
    
    func createPath(_ uid: String? , gender: String?, group: String?, wantRate: String?) {
        
        print("about tot make path")
      
        let path = "\(wantRate!)/\(gender!)/\(group!)/uid/\(uid!)"
        print("this is the path...")
        print(path)
        
        oldPhoto(path)
        
    } // end of createPath
    
    func progressReport(_ progress: FIRStorageUploadTask){
        
        
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        try! FIRAuth.auth()!.signOut()
        print("sign out")
        self.performSegue(withIdentifier: "signOut", sender: nil)
        
    }

    

    
    
    
    
    
    // test swipe

}
