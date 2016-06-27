//
//  checkViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/23/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class checkViewController: UIViewController {

    @IBOutlet weak var loginData: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("doublechecking")
                print(user.uid)
                self.loginData.text! = user.uid
            } else {
                // No user is signed in.
            }
        }
    }

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
