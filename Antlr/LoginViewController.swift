//
//  LoginViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/23/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    var uid = "NO USER"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(email: String, password: String) -> String {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            // ...
            if let _ = error {
                
            }
            else{
                print("signed in")
                print((user?.uid)!)
                self.uid = (user?.uid)!
            }
        }
        
        return self.uid
    }
    
    func updatedID() -> String {
        print("this is the updated id: \(uid)")
        return uid
        
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
