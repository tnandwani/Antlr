//
//  MyScoreViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 6/21/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class MyScoreViewController: UIViewController {
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var ref = FIRDatabase.database().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("made it")
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print("made it inside")
            let score = snapshot.value! as? Double
            
            self.scoreLabel.text! = String(Double(round(10 * score!)/10))
        }) { (error) in
            print(error.localizedDescription)
        }

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
