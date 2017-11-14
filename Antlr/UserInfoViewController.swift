//
//  UserInfoViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/26/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class UserInfoViewController: UIViewController {
    
    var uid = ""
    
    var ref = FIRDatabase.database().reference()
    
    struct AntlrUser {
        static var uid, gender, wantRate, toRate, group: String?
    }
    
    // Gender
    @IBAction func genderButton(_ sender: UIButton) {
        let choice: String = (sender.titleLabel?.text)!
        print(choice)
        AntlrUser.gender  = choice
        
     self.ref.child("users/\(uid)/gender").setValue(choice)
        
    }
    
    // want rating?
    @IBAction func wantRating(_ sender: UIButton) {
        let choice: String = (sender.titleLabel?.text)!
        print(choice)
        AntlrUser.wantRate = choice
        
     self.ref.child("users/\(uid)/wantRate").setValue(choice)
    }
    
    // want to rate?
    @IBAction func toRate(_ sender: UIButton) {
        var choice: String = (sender.titleLabel?.text)!
        
        
        if choice == "GUYS"{
            choice = "GUY"
        }
        if choice == "GIRLS" {
            choice = "GIRL"
        }
        if choice == "EVERYONE"{
            choice = "EVERYONE"
        }
        print(choice)
        AntlrUser.toRate = choice
        
     self.ref.child("users/\(uid)/toRate").setValue(choice)
    }
    
    // group choice
    @IBAction func group(_ sender: UIButton) {
        let choice: String = (sender.titleLabel?.text)!
        print(choice)
        AntlrUser.group = choice
        
        self.ref.child("users/\(uid)/group").setValue(choice)
        self.ref.child("users/\(uid)/uid").setValue(uid)
        
        //data Structure initialize
        
        // user tree
        self.ref.child("users/\(AntlrUser.uid!)/count").setValue(1)
        self.ref.child("users/\(AntlrUser.uid!)/score").setValue(10)
        self.ref.child("users/\(AntlrUser.uid!)/skipped").setValue(0)
        self.ref.child("users/\(AntlrUser.uid!)/spamClicked").setValue(0)
        
        
        // specify photo tree
    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.gender!)/\(AntlrUser.group!)/uid/").child("\(AntlrUser.uid!)/uid").setValue(AntlrUser.uid!)
    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.gender!)/\(AntlrUser.group!)/uid/\(AntlrUser.uid!)/count").setValue(1)
    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.gender!)/\(AntlrUser.group!)/uid/\(AntlrUser.uid!)/score").setValue(10)
        

        
        
        // FOR EVERYONE

    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.toRate!)/\(AntlrUser.group!)/uid/").child("\(AntlrUser.uid!)/uid").setValue(AntlrUser.uid!)
    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.toRate!)/\(AntlrUser.group!)/uid/\(AntlrUser.uid!)/count").setValue(1)
    self.ref.child("photos/\(AntlrUser.wantRate!)/\(AntlrUser.toRate!)/\(AntlrUser.group!)/uid/\(AntlrUser.uid!)/score").setValue(10)
        
        

        
        
            //done with setup
            self.performSegue(withIdentifier: "userDone", sender: nil)
        
    }

        override func viewDidLoad() {
        super.viewDidLoad()
            self.ref = FIRDatabase.database().reference()

            FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                if let user = user {
                    self.uid = user.uid
                    print("signed in as \(self.uid)")
                    AntlrUser.uid = user.uid
                    
                    // User is signed in.
                } else {
                    // No user is signed in.
                }
            }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
