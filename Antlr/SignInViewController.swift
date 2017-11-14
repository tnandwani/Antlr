//
//  SignInViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/18/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignInViewController: UIViewController{
    
    var userBool = false
    
    var uid: String?

    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        passwordBox.resignFirstResponder()
        loading.startAnimating()
        if ( emailBox!.text! !=  ""){
            let email = emailBox!.text!
            if ( passwordBox!.text! != ""){
                let password = passwordBox!.text!
                // perform login here
                print("about to login")
              
                
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    // ...
                    if let error = error {
                        self.errorMessage.text = error.localizedDescription
                        self.passwordBox.text = nil
                        self.loginButton(sender)
                        self.loading.stopAnimating()
  
                    }
                    else{
                        self.loading.stopAnimating()
                        
                        self.userBool = true
                        print("signed in")
                        self.uid = (user?.uid)!
                        print((self.uid)!)
                        self.performSegue(withIdentifier: "oldLogin", sender: nil)
                    }
                } // END OF AUTH
            }
            else {
                errorMessage.text = "Try Again"
            }
        }
        else {
            errorMessage?.text! = "Please enter Email"
        }
        
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
