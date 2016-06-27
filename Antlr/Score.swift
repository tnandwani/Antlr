//
//  Score.swift
//  Antlr
//
//  Created by Tushar Nandwani on 6/16/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Score{
    

    let ref = FIRDatabase.database().reference()
    

    var newSkipped, newScore, newCount: Int?
    
    struct finalValues {
      static var currentUser: String?
    }
    
    func updateData(){
        print("about to update for user....")
        print(finalValues.currentUser)
        ref.child("users").child(finalValues.currentUser!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            print("updating old values now")
            let updatedScore = snapshot.value!["score"] as? Double
            let updatedCount = snapshot.value!["count"] as? Double
            let updatedSkipped = snapshot.value!["skipped"] as? Double
            print("updated score is...")
            print(updatedScore)
            self.validate(updatedScore, oldCount: updatedCount, oldSkipped: updatedSkipped)

        }) { (error) in
            print("done goofed")
            print(error.localizedDescription)
        }
        
        print("finished updating for current user")
    } // end of update
    
    func saveNewData (incomingScore: Int?, incomingCount: Int?, incomingSkipped: Int?){
        print("saving new data...")
        print(incomingScore)
        print(incomingCount)
        print(incomingSkipped)
        
        newScore = incomingScore!
        newCount = incomingCount!
        newSkipped = incomingSkipped!
        print("finshed saving new data")
        updateData()
    }
    
    func validate(oldScore: Double?, oldCount: Double?, oldSkipped: Double?){
        print("old is...")
        print(oldScore)
        print("new is...")
        print(newScore)
        
        var finalSkipped, finalScore, finalCount: Double?
        
        let countPlus = oldCount! + 1

        
        
        print("about to validate")
        
        // if not skipped
        if newSkipped! == 0 {
            print("was not skipped")
            print("old score is... \(oldScore!)")
            
            
            // if not valid
            if (oldCount! > 5 && abs(Double(newScore!) - oldScore!) > 3){
                print("not a valid rating ")
                finalScore = oldScore
                finalCount = oldCount
                
               print("graded")
                
            } // end not valid
            
            // if more than 5
            if (oldCount! > 5 && abs(Double(newScore!) - oldScore!) <= 5){
                print("count was more than 5")
                finalScore = ((oldScore! * oldCount!) + Double(newScore!)) / countPlus
                finalCount = countPlus
                finalSkipped = oldSkipped!
                
                print("graded")
                
            } // end more than 5
            
            // if less than 5
            if (oldCount! <= 5){
            print("count was less than 5")
                
            finalScore = ((oldScore! * oldCount!) + Double(newScore!)) / countPlus
            finalCount = countPlus
            finalSkipped = oldSkipped!
                
            
            print("graded")
                
            } // end less than 5
            

        } // end not skipped
        
        // if skipped
        if newSkipped! == 1{
            print("skipped")
            finalCount = oldCount!
            finalScore = oldScore!
            finalSkipped = oldSkipped! + 1 
        }
        

        // set final skipped
        finalSkipped = oldSkipped! + Double(newSkipped!)
        
        print("final score is.. \(finalScore!)")
        print("final count is.. \(finalCount!)")
        print("final skipped is.. \(finalSkipped!)")
        
        uploadData(finalScore!, newCount: finalCount, newSkipped: finalSkipped)
        print("sent upload method")

        
    }// end of validate
  
    func uploadData(newScore: Double?, newCount: Double?, newSkipped: Double?){
        print("about to upload new data to cloud")
        self.ref.child("users/\(finalValues.currentUser!)/count").setValue(newCount!)
        self.ref.child("users/\(finalValues.currentUser!)/score").setValue(newScore!)
        self.ref.child("users/\(finalValues.currentUser!)/skipped").setValue(newSkipped!)
        print("finished uploading data to cloud")
    }
}
