//
//  CreateViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/19/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateViewController: UIViewController {

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var checkBox: UITextField!
    var uid: String?

  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createButton(sender: UIButton) {
        print(emailBox!.text!)
        if ( emailBox!.text! !=  "" && (emailBox.text?.containsString("@"))!){
            let email = emailBox!.text!
            print(email)
            if ( passwordBox!.text! != ""){
                let password = passwordBox!.text!
                print((password))
                if (checkBox!.text! != ""){
                    let check = checkBox!.text!
                    print(check)
                    if (check == password){
                        print("about to create user")
                        if password.characters.count >= 6 {
                            print(password.characters.count)
                            //start of login
                            FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
                                if let error = error {
                                    self.errorMessage.text! =  error.localizedDescription
                                    return
                                }
                                print(email)
                                print(password)
                                print("USER CREATED")
                                self.uid = user?.uid
                                print((self.uid)!)
                                self.performSegueWithIdentifier("startOptions", sender: nil)
                                // ...
                                
                                // end of login
                            }
                        }
                        else {
                            errorMessage.text! = "Password must be at least 6 characters"
                        }
                    
                       
                    }
                    else {
                        errorMessage?.text! = "Passwords Do Not Match"
                        
                    }
                }
                else {
                    errorMessage?.text! = "Please Re-Enter Password"
                }
            }
            else{
                errorMessage.text = "Please Enter Password"
            }
        }
        else {
            errorMessage?.text! = "Please Enter Valid Email"
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
