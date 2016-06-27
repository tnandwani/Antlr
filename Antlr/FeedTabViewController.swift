//
//  FeedTabViewController.swift
//  Antlr
//
//  Created by Tushar Nandwani on 5/28/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseCrash

class FeedTabViewController: UIViewController {
    
    
    // picture and firebase setup
    
    var storageRef = FIRStorage.storage().referenceForURL("gs://project-4762449512525788408.appspot.com")
    let ref = FIRDatabase.database().reference()
    var scoreSystem = Score()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var picNum = 0
    
    var currentUser: String?
    
    var uidList: [String]?
    
    var score: Int = 5 {
        didSet {
            score = min( max(score, 1), 10)
            scoreLabel.text! = String(score)
        }
    }
    
    var array: [UIImage]?
    var userCount: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.startAnimating()
        updateData()
        
        
        
        // swipe stuff
        
    } // end view did load
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateData(){
        print("about to update")
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let updatedGender = snapshot.value!["gender"] as? String
            let updatedGroup = snapshot.value!["group"] as? String
            let updatedWantRate = snapshot.value!["wantRate"] as? String
            let updatedToRate = snapshot.value!["toRate"] as? String
            
            self.createBasePath(updatedGender, group: updatedGroup, wantRate: updatedWantRate, toRate: updatedToRate)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print("finished updating")
    } // end of update
    
    func createBasePath(gender: String?, group: String?, wantRate: String?, toRate: String?) {
        print("creating path")
        
        let basePath = "photos/YES/\(toRate!)/\(group!)"
        
        uidList(basePath)
        print("finished creating search path..")
        print(basePath)
        
        
    } // end of createPath
    
    func uidList(path: String){
        
        print("making list")
        
        let basePath = ref.child(path)
        
        basePath.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject]
            
            if postDict != nil{
                
                let userList = Array(postDict!.keys)
                print("self uid list is.. \(userList)")
                
                
                // list of images
                for userList in userList {
                    let newPath = ("\(path)/")
                    self.loadImages(newPath, currentUID: userList)
                    
                }// end of for
                
            } // end if
            
            if postDict == nil {
                self.loading.stopAnimating()
                print("no users there")
            }
            
            // add invite friends link???
            
        }) // end of observe
        
        print("finished making list")
    } // end uidlist
    
    
    func loadImages (path: String, currentUID: String) {
        print("about to load photos")
        
        //Create a reference to the file you want to download
        
        var newPath = path.stringByReplacingOccurrencesOfString("photos/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newPath = newPath + currentUID
        
        let imageRef = storageRef.child("\(newPath).jpeg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print("no photo is available")
                self.loading.stopAnimating()
                // Uh-oh, an error occurred!
            } else {
                
                print("rate this photo")
                
                let profileImage = UIImage(data: data!)
                self.makeUIDArray(currentUID)
                self.updateImage(profileImage!)
            } // success download
        }
        
    } // end of load photo
    
    
    
    func createArray(image: UIImage){
        
        if array != nil {
            array!.append(image)
        }
        if array == nil{
            array = [image]
        }
        if array?.count > 0 {
            newPic(picNum)
            
        }
    }
    
    func updateImage(image: UIImage){
        createArray(image)
    }
    
    
    
    // new gesture stuff
    
    private struct Constants{
        static let scale: CGFloat = 50
    }
    
    @IBAction func rateGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case . Ended:
            let swipe = gesture.translationInView(imageView)
            let swipeChange = -Int(swipe.x)
            
            if swipeChange > 150 {
                print("NEXT")
                let nextNum = picNum + 1
                currentUser = uidList?[picNum]
                Score.finalValues.currentUser = currentUser
                print("now showing user... \(currentUser).. who is user... \(picNum + 1).. out of \(array?.count)")
                
                
                // index check
                if array?.count > nextNum{
                    // if rated
                    if self.scoreLabel.text != ""{
                        print(currentUser!)
                        Score.finalValues.currentUser = currentUser
                        self.scoreSystem.saveNewData(Int(self.scoreLabel.text!), incomingCount: 1 , incomingSkipped: 0)
                    }
                    
                    
                    
                    // if not rated
                    if self.scoreLabel.text == ""{
                        print(currentUser!)
                        self.scoreSystem.saveNewData(10, incomingCount: 1 , incomingSkipped: 1)
                    }
                    
                    newPic(nextNum)
                    
                    // reset label
                    self.scoreLabel.text = ""
                    picNum = nextNum
                    
                } // end if next available
                
                
                
                
                
                
                if array?.count < nextNum + 1 {
                    print("out of pics, invite your friends please")
                    FIRCrashMessage("NO MORE USERS")
                    fatalError()
                    let alertController = UIAlertController(title: "ANTLR", message:
                        "Out of people to rate :(", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "INVITE FRIENDS", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                
            }
            
            if swipeChange < -150 {
                print("PREVIOUS")
                currentUser = uidList?[picNum]
                Score.finalValues.currentUser = currentUser
                let lastNum = picNum - 1
                if lastNum >=  0 {
                    // if previous
                    newPic(lastNum)
                    print("now showing user... \(currentUser).. who is user... \(lastNum).. out of \(uidList?.count)")
                    
                    picNum = lastNum
                    self.scoreLabel.text = ""
                }
                
            }
            
        case .Changed :
            let translation = gesture.translationInView(imageView)
            let scoreChange = -Int(translation.y / Constants.scale)
            
            if scoreChange != 0 {
                score += scoreChange
                gesture.setTranslation(CGPointZero, inView: imageView)
                
            }
            
        default: break
        }
    }
    
    func newPic(thisOne: Int){
        let newImage = array?[thisOne]
        loading.stopAnimating()
        imageView.image = newImage!
    }
    
    // spam
    
    @IBAction func spamButton(sender: UIBarButtonItem) {
        scoreLabel.text = ""
        currentUser = uidList?[picNum]
        print(currentUser!)
        
        // mark as spam here
        
        ref.child("users").child(currentUser!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            var spamClicked = snapshot.value!["spamClicked"] as? Int
            print(spamClicked)
            spamClicked! += 1
            self.ref.child("users/\(self.currentUser!)/spamClicked").setValue(spamClicked!)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if (picNum + 1) < array?.count{
            picNum += 1
            newPic(picNum)
        }
        if picNum >= array?.count{
            print("no more spam wasubui")
        }
        
        
    }
    
    func makeUIDArray(id: String){
        if uidList != nil {
            uidList!.append(id)
        }
        if uidList == nil{
            uidList = [id]
            print("array size is.. \((uidList?.count)! + 1)")
        }
    }
    
    
    
    
} // end of class 

