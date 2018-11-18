//
//  SomeBroadcastViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class SomeBroadcastViewController: UIViewController {
    
    var creatorUserId: String?
    
    @IBOutlet weak var sbTitle: UILabel!
    @IBOutlet weak var sbDescription: UITextView!
    @IBOutlet weak var sbStatus: UILabel!
    
    @IBOutlet weak var dropRequestBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    
    @IBOutlet weak var theirProfileBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sbStatus.isHidden = true
        getBroadcastDetailsFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dropRequestBtnClicked(_ sender: UIButton) {
        print("Drop Request Button Clicked")
        
        doIEvenHaveARequestForThis() { success in
            if success == false {
                //show popup saying can't create
                let refreshAlert = UIAlertController(title: "Oooops!", message: "You don't have any active request to drop.", preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(refreshAlert, animated: true, completion: nil)
            }
            else {
                let ref = Database.database().reference()
                let requestReference = ref.child("broadcasts").child(self.creatorUserId!).child("requests").child((Auth.auth().currentUser?.uid)!)
                requestReference.removeValue()
                let requestReference2 = ref.child("individualrequests").child((Auth.auth().currentUser?.uid)!)
                requestReference2.removeValue()
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func sendRequestBtnClicked(_ sender: UIButton) {
        print("Send Request Button Clicked")
        
        doIHaveMyOwnBroadcast() { success in
            if success == true {
                //show popup saying can't create
                let refreshAlert = UIAlertController(title: "Oooops!", message: "You have an active brodcast. Delete that broadcast to continue.", preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(refreshAlert, animated: true, completion: nil)
            }
            else {
                self.registerRequestIntoDatabase()
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func theirProfileBtnClicked(_ sender: UIButton) {
        print("Their Profile Button Clicked")
        
        isMyRequestAccepted() { success in
            if success == false {
                let refreshAlert = UIAlertController(title: "Oooops!", message: "Your request is not accepted yet. Please wait.", preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(refreshAlert, animated: true, completion: nil)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "RequestViewController1") as! RequestViewController
                vc.userid = self.creatorUserId!
                vc.isOnlyView = true
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func sbCloseBtnClicked(_ sender: UIButton) {
        print("Close Button Clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    func doIEvenHaveARequestForThis(completion: @escaping (Bool) -> ()) {
        print("Came inside doIEvenHaveARequestForThis")
        var answer = false
        let ref = Database.database().reference()
        let reqReference = ref.child("broadcasts").child(self.creatorUserId!).child("requests").child((Auth.auth().currentUser?.uid)!)
        reqReference.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            var numberofrequests = snapshot.children.allObjects.count
            if numberofrequests == 0 {
                answer = false
            }
            else {
                answer = true
            }
            completion(answer)
        })
    }
    
    func doIHaveMyOwnBroadcast(completion: @escaping (Bool) -> ()) {
        print("Came inside doIHaveMyOwnBroadcast")
        var answer = false
        let ref = Database.database().reference()
        let reqReference = ref.child("broadcasts").child((Auth.auth().currentUser?.uid)!)
        reqReference.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            var numberof = snapshot.children.allObjects.count
            if numberof == 0 {
                answer = false
            }
            else {
                answer = true
            }
            completion(answer)
        })
    }
    
    func isMyRequestAccepted(completion: @escaping (Bool) -> ()) {
        print("Came inside isMyRequestAccepted")
        let ref = Database.database().reference().child("broadcasts").child(self.creatorUserId!).child("requests")
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                var useridforthisrequest = (snap as! DataSnapshot).key
                print(useridforthisrequest)
                print("came inside for loop inside ref observe..")
                if useridforthisrequest == (Auth.auth().currentUser?.uid)! {
                    if let dictionary = (snap as! DataSnapshot).value as! [String:Any]?
                    {
                        var thisrequest = RequestForBroadcast(dictionary: dictionary as [String : AnyObject])
                        if thisrequest.status! == "A" {
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                }
            }
            completion(false)
        })
    }
    
    func getBroadcastDetailsFromDB()
    {
        print("Came inside getBroadcastDetailsFromDB")
        // Read Broadcast information from DB
        Database.database().reference().child("broadcasts").child(creatorUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("came inside first step")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let thisBroadcast = MyBroadcast(dictionary: dictionary)
                self.sbTitle.text = thisBroadcast.title!
                self.sbDescription.text = thisBroadcast.mydescription!
            }
        }, withCancel: nil)
        
    Database.database().reference().child("broadcasts").child(creatorUserId!).child("requests").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("came inside first step in requests")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let thisBroadcastRequest = RequestForBroadcast(dictionary: dictionary)
                if thisBroadcastRequest.status == "R" {
                    self.sbStatus.isHidden = false
                    self.sbStatus.text = "Status: Rejected"
                }
                else if thisBroadcastRequest.status == "A" {
                    self.sbStatus.isHidden = false
                    self.sbStatus.text = "Status: Accepted"
                }
                else if thisBroadcastRequest.status == "P" {
                    self.sbStatus.isHidden = false
                    self.sbStatus.text = "Status: Pending"
                }
            }
        }, withCancel: nil)
    }
    
    private func registerRequestIntoDatabase() {
        
        let ref = Database.database().reference()
        let requestReference = ref.child("broadcasts").child(creatorUserId!).child("requests").child((Auth.auth().currentUser?.uid)!)
        let values = ["status": "P"] as [String : AnyObject]
        requestReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        
        let requestReference2 = ref.child("individualrequests").child((Auth.auth().currentUser?.uid)!)
        let values2 = ["broadcasterid": creatorUserId!, "status": "P"] as [String : AnyObject]
        requestReference2.updateChildValues(values2, withCompletionBlock: { (err, ref) in
            if err != nil {
                print ("some error in writing request...")
                print(err ?? "")
                return
            }
        })
        
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
