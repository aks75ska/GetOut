//
//  RequestViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/25/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class RequestViewController: UIViewController {
    
    var userid: String?
    var isOnlyView = false
    
    @IBOutlet weak var requestImage: UIImageView!
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestAge: UILabel!
    @IBOutlet weak var requestPhone: UILabel!
    @IBOutlet weak var requestMyDesc: UITextView!
    
    @IBOutlet weak var requestRejectBtn: UIButton!
    @IBOutlet weak var requestAcceptBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOnlyView == true {
            requestRejectBtn.isHidden = true
            requestAcceptBtn.isHidden = true
        }
        else {
            requestRejectBtn.isHidden = false
            requestAcceptBtn.isHidden = false
        }

        // Do any additional setup after loading the view.
        fetchUserProfile()
        fetchDP()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func requestRejectBtnClicked(_ sender: UIButton) {
        let ref = Database.database().reference()
        let requestReference = ref.child("broadcasts").child((Auth.auth().currentUser?.uid)!).child("requests").child(self.userid!)
        let values = ["status": "R"] as [String : AnyObject]
        requestReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        
        let requestReference2 = ref.child("individualrequests").child(self.userid!)
        let values2 = ["broadcasterid": (Auth.auth().currentUser?.uid)!, "status": "R"] as [String : AnyObject]
        requestReference2.updateChildValues(values2, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func requestAcceptBtnClicked(_ sender: UIButton) {
        let ref = Database.database().reference()
        let requestReference = ref.child("broadcasts").child((Auth.auth().currentUser?.uid)!).child("requests").child(self.userid!)
        let values = ["status": "A"] as [String : AnyObject]
        requestReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        
        let requestReference2 = ref.child("individualrequests").child(self.userid!)
        let values2 = ["broadcasterid": (Auth.auth().currentUser?.uid)!, "status": "A"] as [String : AnyObject]
        requestReference2.updateChildValues(values2, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func requestCloseBtnClicked(_ sender: UIButton) {
        print("Close Button Clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUserProfile() {
        print("CAme to fetch user profile")
        // Read User information from DB
        Database.database().reference().child("users").child(userid!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("came inside first step")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = MyUser(dictionary: dictionary)
                if user.name == nil {
                    print("username not found in db")
                }
                else {
                    self.requestName.text = user.name!
                }
                if user.phone == nil {
                    print("userphone not found in db")
                }
                else {
                    self.requestPhone.text = user.phone!
                }
                if user.age == nil {
                    print("userage not found in db")
                }
                else {
                    self.requestAge.text = user.age!
                }
                if user.myDescription == nil {
                    print("user description not found in db")
                }
                else {
                    self.requestMyDesc.text = user.myDescription!
                }
            }
            
        }, withCancel: nil)
    }
    
    private func fetchDP() {
        print("Fetch DP called...")
        let imageName = userid!
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        // Fetch the download URL
        storageRef.downloadURL { url, error in
            if let error = error {
                // Handle any errors
                print("some error occured in downloading image")
            } else {
                // Get the download URL for 'images/stars.jpg'
                print("Download image from url: " + String(describing: url!))
                let data = NSData(contentsOf: url! as URL)
                if data != nil {
                    self.requestImage.image  = UIImage(data: data! as Data)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
