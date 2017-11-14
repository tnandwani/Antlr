//
//  FeedTabViewController2.swift
//  Antlr
//
//  Created by Tushar Nandwani on 6/29/16.
//  Copyright © 2016 Tushar Nandwani. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseCrash
import Crashlytics
import Fabric
import MessageUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class FeedTabViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    
    // firebase setup
    // firebase setup
    var storageRef = FIRStorage.storage().reference(forURL: "gs://project-4762449512525788408.appspot.com")
    let ref = FIRDatabase.database().reference()
    var scoreSystem = Score()

    // gesture control
    var score: Int = 5 {
        didSet {
            score = min( max(score, 1), 10)
            scoreLabel.text! = String(score)
        }
    }
    
    ////////////////////////////////////////////////////////////
    
    var imageArray: [UIImage]?
    var uidArray: [String]?
    var imageArrayID: [String]?
    var ratedUidArray: [String] = ["RATED USERS::::"]
    
    var imageIndex: Int?
    var uidIndex: Int?

    var imageArraySize: Int?
    var uidArraySize: Int?

    
    var downloadPath: String?
    var photoPath: String?
    var everyonePath: String?
    
    var initialCount: Int?
    
    var savedCurrentUser: String = "NO USER"
    
    var remaining = 3
    /////////////////////////////////////////////////////////////
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
          print("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
          print("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
        updateData()
        // Do any additional setup after loading the view.
    }
    
    
    // outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateData(){
        print("BEGIN FEED TAB CONTROLLER")
        print("about to update")
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let updatedGroup = snapshot.value! as? String
            let updatedToRate = snapshot.value! as? String
            
            let pathExt = "photos/YES/\(updatedToRate!)/\(updatedGroup!)/uid"
            let everyonePath = "photos/YES/EVERYONE/\(updatedGroup!)/uid"
            self.createUIDList(pathExt, everyPath: everyonePath)
            print("THIS IS THE PROBLEM HERE.... \(updatedToRate)")
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print("finished updating")
    } // end of update
    
    
  /////////////////////////////////////////////////////////
    func createUIDList(_ pathExt: String, everyPath: String){
        
        photoPath = pathExt
        everyonePath = everyPath

        // wherer to look
        
        
        print("SORTING UIDS IN.... \(pathExt)")
        // My top posts by number of stars
        let myTopPostsQuery = (ref.child(pathExt).queryOrdered(byChild: "count").queryLimited(toFirst: 50))
        
        
        myTopPostsQuery.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject]
            
            if postDict != nil{
                
                let userList = Array(postDict!.keys)
                print("starting uid list is.. \(userList)")
                
                let finalPath = pathExt.replacingOccurrences(of: "photos/", with: "", options: NSString.CompareOptions.literal, range: nil)
                self.prepare(userList, path: finalPath)
                
                
                
                // userList is list of users 
                // finalPath is dowload path without user ext
                
            } // end if
            
            if postDict == nil {
                print("no users there")
            }
            
            
        }) // end of observe
        
    }
    
    ///////////////////////////////////////////////////////
     func prepare(_ list: [String], path: String){
        uidArray = list
        downloadPath = path
        saveVariables(list, path: path)
    }
    
  /////////////////////////////////////////////////////////
    func saveVariables(_ list: [String], path: String){
        uidArray = list
        downloadPath = path
        startingPhotos()
    }
    
  /////////////////////////////////////////////////////////
    func startingPhotos(){
        imageIndex = 0
        uidIndex = 0
        
        if imageArray?.count == nil{
            downloadImage(uidIndex!)
        }

    }
    
  /////////////////////////////////////////////////////////
    func downloadImage(_ index: Int){
        let user = uidArray![index]
        let userPath = downloadPath! + "/" + user
        savedCurrentUser = user

        
        let imageRef = storageRef.child("\(userPath).jpeg")
        
       let downloadTask = imageRef.data(withMaxSize: 5 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                if self.uidArray?.count <= 1{
                    self.stopSpinning()
                }
                print("no photo is available")
                // Uh-oh, an error occurred!
            } else {
                
                print("photo loaded")
                let profileImage = UIImage(data: data!)
                self.saveStartingPhotos(profileImage!, user: user)
                 // success download
            }

        }
        
        downloadTask.observe(.resume) { (snapshot) -> Void in
            // Download reported progress
                self.counter()
        }

    }
    
    func stopSpinning(){
        loading.stopAnimating()
    }
    
    func counter(){

        if initialCount != nil{
            initialCount! += 1
            
        }
        if initialCount == nil {
            initialCount = 1
        }
        
        if initialCount < 3 {
            if uidArray?.count > (uidIndex! + 1){
                uidIndex! += 1
                downloadImage(uidIndex!)
            }
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////
    func saveStartingPhotos(_ image: UIImage, user: String){
        if imageArray?.count != nil{
            print("added more photos")
            ratedUidArray.append(user)
            imageArray!.append(image)
            imageArrayID!.append(user)
            // show first photo
            showImage(user)
        }
        
        if imageArray?.count == nil{
            print("added first image")
            ratedUidArray.append(user)
            imageArray = [image]
            imageArrayID = [user]
            showImage(user)
        }
        
    }
    
    
    func downloadMoreImage(_ index: Int){
        print("getting more")
        
        let user = uidArray![index]
    
        
        if ratedUidArray.contains(user) {
            tryAgain(index)
        }
        else{
            let userPath = downloadPath! + "/" + user
            
            
            let imageRef = storageRef.child("\(userPath).jpeg")

            imageRef.data(withMaxSize: 5 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print("no photo is available")
                    self.tryAgain(index)
                    // Uh-oh, an error occurred!
                } else {
                    print("photo loaded")
                    let profileImage = UIImage(data: data!)
                    self.saveMore(profileImage!, user: user)
                    // success download
                }
            }
        }
    }
    
    func tryAgain(_ index: Int){
        print("TRYING AGAIN")
        if uidArray?.count > (index + 1 ){
            print(uidArray?[(index + 1)])
            downloadMoreImage(index+1)
        }
        else{
            print("INVTE FRIENDS TO BETA")
            remaining = 0
       
        }
        
    }

    func saveMore(_ image: UIImage, user: String){
        if imageArray?.count != nil{
            print("added more photos")
                        ratedUidArray.append(user)
            imageArray!.append(image)
            imageArrayID!.append(user)
            // show first photo
            showImage(user)
        }
        
        if imageArray?.count == nil{
            print("added first image")
                        ratedUidArray.append(user)
            imageArray = [image]
            imageArrayID = [user]
        }
        
    }
    
    func showImage(_ user: String){
        
        loading.stopAnimating()
        imageView.image = imageArray![0]
        print("NOW SHOWING.... \(imageArrayID![0])")
        print("LOADED PHOTOS OF.... \(imageArrayID)")
        print("NUMBER OF PHOTOS LOADED... \(imageArray?.count)")
        
    }
    
    
    

    ///////////////////////////////////////////////////////////////////    ///////////////////////////////////////////////////////////////////    ///////////////////////////////////////////////////////////////////    ///////////////////////////////////////////////////////////////////
    
    
    fileprivate struct Constants{
        static let scale: CGFloat = 50
    }
    
    @IBAction func rateGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case . ended:
            
            let swipe = gesture.translation(in: imageView)
            let swipeChange = -Int(swipe.x)
            
            let currentUser = imageArrayID![imageIndex!]
            Answers.logCustomEvent(withName: "rate user", customAttributes: nil)
            
            // NEXT ACTION
            if swipeChange > 150 {

                
                if scoreLabel.text == "" {
                    print("SKIPPED... \(savedCurrentUser)")
                    self.scoreSystem.saveNewData(10, incomingCount: 1 , incomingSkipped: 1, user: currentUser, everyPath: everyonePath!, specificPath: photoPath!)
                } // end skipped
                
                if scoreLabel.text != "" {
                    print("RATED... \(savedCurrentUser)")
                    self.scoreSystem.saveNewData(Int(self.scoreLabel.text!), incomingCount: 1 , incomingSkipped: 0, user: currentUser, everyPath: everyonePath!, specificPath: photoPath!)
                }
                
                // if next available
                if imageArray?.count > 1{
                    // once next
                    print("NEXT")
                    imageIndex! += 1
                    self.scoreLabel.text = ""
                    
                    
                    // start data refresh here
                    imageArray?.remove(at: 0)
                    // print rated
                    print(ratedUidArray)
                    imageArrayID?.remove(at: 0)
                    downloadMoreImage(imageIndex!)
                    showImage(savedCurrentUser)
                }
                else {
                    remaining -= 1
                    print("NO MO FRIENDS.. \(remaining)  photos remaining")
                    if remaining < 1{
                        print("sending beta alert")
                        betaAlert()
                    }
                }

            }
            
        case .changed :
            let translation = gesture.translation(in: imageView)
            let scoreChange = -Int(translation.y / Constants.scale)
            
            if scoreChange != 0 {
                score += scoreChange
                gesture.setTranslation(CGPoint.zero, in: imageView)
                
            }
            
            
        default: break
        }
    }
    
    
    func sendText() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "https://betas.to/qycy13x7"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func betaAlert(){
        
        print("NOW SHOWING BETA ALERT")
        
        let inviteAlert = UIAlertController(title: "BETA", message: "Out of people to rate", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        inviteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        
        inviteAlert.addAction(UIAlertAction(title: "Invite Friends", style: .default, handler: { (action: UIAlertAction!) in
            self.sendText()
        }))
        
        
        
        
        present(inviteAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func spamButton(_ sender: UIBarButtonItem) {
        scoreSystem.spam(imageArrayID![0])
        
        // if next available
        if imageArray?.count > 1{
            // once next
            print("NEXT")
            imageIndex! += 1
            self.scoreLabel.text = ""
            
            
            // start data refresh here
            imageArray?.remove(at: 0)
            // print rated
            print(ratedUidArray)
            imageArrayID?.remove(at: 0)
            downloadMoreImage(imageIndex!)
            showImage(savedCurrentUser)
        }
        else {
            remaining -= 1
            print("NO MO FRIENDS.. \(remaining)  photos remaining")
            if remaining < 1{
                print("sending beta alert")
                betaAlert()
            }
        }
        
        
    }
    
    
} // end of feed controller
