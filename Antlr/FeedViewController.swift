//
//  FeedViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/20/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var profile: UIImageView!
    var login = LoginViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = login.updatedID()
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://project-4762449512525788408.appspot.com")
        let imageRef = storageRef.child("\(uid)/IMG_2548.JPG")
        print("this is the url")
        print(imageRef.fullPath)
        
        
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let profileImage: UIImage  = UIImage(data: data!)!
                self.profile.image = profileImage
                
            } // got pic
        } // end of get pic

} // end of view did load

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
