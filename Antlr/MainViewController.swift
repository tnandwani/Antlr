//
//  ViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/18/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//


import UIKit
import FirebaseAuth
import Firebase
import TwitterKit



class MainViewController: UIViewController, GIDSignInUIDelegate {
    

    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func TwitterButton(_ sender: UIButton) {
        
        Twitter.sharedInstance().logIn {
            (session, error) -> Void in
            if (session != nil) {
                print(session?.authToken)
                
                let credential = FIRTwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    print("account created for user...")
                    print(user?.uid)
                    
                    FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                        if let user = user {
                            print("signed in as... \(user.uid)")
                            self.login(user.uid)
                            // User is signed in.
                        } else {
                            print("no one :(")
                            // No user is signed in.
                        }
                    }
                    
                }
                
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }

    }
    @IBAction func GoogleSignInButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                self.login(user.uid)
                // User is signed in.
            } else {
                // No user is signed in.
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // google button
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(_ uid: String){
        checkUID(uid)
    }
    
    func checkUID(_ currentUID: String){
        print("checking UID.. \(currentUID)")
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let user = snapshot.value! as? String
            
            if user == nil{
                // no user exists
                print("newLogin")
                self.performSegue(withIdentifier: "newAuthLogin", sender: nil)
            }
            
            if user != nil{
                // user exists
                print("oldLogin")
                self.performSegue(withIdentifier: "oldAuthLogin", sender: nil)
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
     
        
    }
    
    


}

