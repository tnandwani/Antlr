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
    var currentUser: String?
    var updatedSpam = 1
    
    var photoPath: String?
    var everyonePath: String?
    
    
    func updateData(){
        ref.child("users").child(currentUser!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let updatedScore = snapshot.value! as? Double
            let updatedCount = snapshot.value! as? Double
            let updatedSkipped = snapshot.value!  as? Double
            let incomingSpam = snapshot.value! as? Int
            
            self.saveSpam(incomingSpam!)
     
            self.validate(updatedScore, oldCount: updatedCount, oldSkipped: updatedSkipped)

        }) { (error) in
            print("done goofed")
            print(error.localizedDescription)
        }

    } // end of update
    
    func saveUser(_ user: String){
        currentUser = user
    }
    func saveSpam(_ oldSpam: Int){
        updatedSpam = oldSpam
    }
    
    func saveNewData (_ incomingScore: Int?, incomingCount: Int?, incomingSkipped: Int?, user: String, everyPath: String, specificPath: String){
        everyonePath = everyPath
        photoPath = specificPath
        currentUser = user
        newScore = incomingScore!
        newCount = incomingCount!
        newSkipped = incomingSkipped!
        savePaths(everyPath, specificPath: specificPath)
        saveUser(user)
        updateData()
        
    }
    
    func savePaths(_ everyPath: String, specificPath: String){
        everyonePath = everyPath
        photoPath = specificPath
        
    }

    func validate(_ oldScore: Double?, oldCount: Double?, oldSkipped: Double?){
        var finalSkipped, finalScore, finalCount: Double?
        
        let countPlus = oldCount! + 1
        // if not skipped
        if newSkipped! == 0 {
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
            finalCount = oldCount!
            finalScore = oldScore!
            finalSkipped = oldSkipped! + 1 
        }
        

        // set final skipped
        finalSkipped = oldSkipped! + Double(newSkipped!)
//        print("final score is.. \(finalScore!)")
//        print("final count is.. \(finalCount!)")
//        print("final skipped is.. \(finalSkipped!)")
//        
        uploadData(finalScore!, newCount: finalCount, newSkipped: finalSkipped)

        
    }// end of validate
  
    func uploadData(_ newScore: Double?, newCount: Double?, newSkipped: Double?){

        ref.child("users/\(currentUser!)/count").setValue(newCount!)
        ref.child("users/\(currentUser!)/score").setValue(newScore!)
        ref.child("users/\(currentUser!)/skipped").setValue(newSkipped!)
        ref.child("users/\(currentUser!)/skipped").setValue(newSkipped!)
        
        updatePhotoData(newScore!, finalCount: newCount!)
        print("SCORE UPDATE COMPLETE FOR ....\(currentUser)")
        
    }
    
    func updatePhotoData(_ finalScore: Double, finalCount: Double){
    
        // specify photo tree
        ref.child("\(photoPath!)/\(currentUser!)/count").setValue(finalCount)
        ref.child("\(photoPath!)/\(currentUser!)/score").setValue(finalScore)

        // FOR EVERYONE
        ref.child("\(everyonePath!)/\(currentUser!)/count").setValue(finalCount)
        ref.child("\(everyonePath!)/\(currentUser!)/score").setValue(finalScore)
        
    }
    
    
    func spam(_ user: String){
        updatedSpam += 1
        ref.child("users/\(user)/spamClicked").setValue(updatedSpam)
        
    }
}
