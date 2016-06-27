//
//  UserDataViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/23/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit

class UserDataViewController: UIViewController {

    var userUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUID(uid:String?){
        print("setting the uid")
        print((userUID)!)
        
    }
    
    func getUID()-> String?{
        print("getting the UID")
        print("got the uid: \(userUID)")
        return userUID
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
