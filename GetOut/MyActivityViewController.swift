//
//  MyActivityViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class MyActivityViewController: UIViewController {
    
    
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var createBroadcastBtn: UIButton!
    
    @IBOutlet weak var noActivityHelpText: UILabel!
    
    var isMyCreated = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //activityName.isHidden = true
        //createdBy.isHidden = true
        //status.isHidden = true
        //detailsBtn.isHidden = true
        
        //getMyActivityDetailsFromDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("MYActivity View Did Appear..")
        activityName.isHidden = true
        createdBy.isHidden = true
        status.isHidden = true
        detailsBtn.isHidden = true
        noActivityHelpText.isHidden = false
        getMyActivityDetailsFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func detailsBtnClicked(_ sender: UIButton) {
        print("Details button clicked...")
        if self.isMyCreated == true {
            print("Going to edit my own broadcast")
            let myTab = self.tabBarController as! MyTabBarController
            print("Lat: " + String(myTab.myLat) )
            print("Long: " + String(myTab.myLong) )
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateEditBroadcastViewController1") as! CreateEditBroadcastViewController
            vc.myLat = myTab.myLat
            vc.myLong = myTab.myLong
            navigationController?.pushViewController(vc, animated: true)
            //navigationController?.present(vc, animated: true, completion: nil)
        }
        else {
            print("Going to open some broadcast page")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SomeBroadcastViewController1") as! SomeBroadcastViewController
            Database.database().reference().child("individualrequests").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let thisBroadcastRequest = RequestForBroadcast(dictionary: dictionary)
                    vc.creatorUserId = thisBroadcastRequest.userid!
                    //self.navigationController?.present(vc, animated: true, completion: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }, withCancel: nil)
        }
    }
    
    
    @IBAction func createBroadcastBtnClicked(_ sender: UIButton) {
        print("Create Broadcast Button Clicked")
        
        amIRequestingSomeBodyCurrently() { success in
            if success == true {
                //show popup saying can't create
                let refreshAlert = UIAlertController(title: "Oooops!", message: "You have a request pending with a broadcaster. Please drop that request to proceed.", preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(refreshAlert, animated: true, completion: nil)
            }
            else {
                let myTab = self.tabBarController as! MyTabBarController
                print("Lat: " + String(myTab.myLat) )
                print("Long: " + String(myTab.myLong) )
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CreateEditBroadcastViewController1") as! CreateEditBroadcastViewController
                vc.myLat = myTab.myLat
                vc.myLong = myTab.myLong
                self.navigationController?.pushViewController(vc, animated: true)
                //navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func amIRequestingSomeBodyCurrently(completion: @escaping (Bool) -> ()) {
        print("Came inside amIRequestingSomeBodyCurrently")
        var answer = false
        let ref = Database.database().reference()
        let reqReference = ref.child("individualrequests").child((Auth.auth().currentUser?.uid)!)
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
    
    func getMyActivityDetailsFromDB()
    {
        print("Came inside getMyActivityDetailsFromDB")
        // Read activity information from DB
        Database.database().reference().child("broadcasts").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("came inside first step")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let thisBroadcast = MyBroadcast(dictionary: dictionary)
                self.activityName.text = thisBroadcast.title!
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("came inside first step")
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let user = MyUser(dictionary: dictionary)
                            self.createdBy.text = user.name! + "(Me!)"
                    }
                    
                }, withCancel: nil)
                self.activityName.isHidden = false
                self.createdBy.isHidden = false
                self.status.isHidden = true
                self.detailsBtn.isHidden = false
                self.isMyCreated = true
                self.noActivityHelpText.isHidden = true
            }
        }, withCancel: nil)
        
        Database.database().reference().child("individualrequests").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("came inside first step in requests")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let thisBroadcastRequest = RequestForBroadcast(dictionary: dictionary)
                self.activityName.isHidden = false
                self.createdBy.isHidden = false
                self.status.isHidden = false
                self.detailsBtn.isHidden = false
                self.isMyCreated = false
                self.noActivityHelpText.isHidden = true
                if thisBroadcastRequest.status == "R" {
                    self.status.text = "Status: Rejected"
                }
                else if thisBroadcastRequest.status == "A" {
                    self.status.text = "Status: Accepted"
                }
                else if thisBroadcastRequest.status == "P" {
                    self.status.text = "Status: Pending"
                }
                Database.database().reference().child("broadcasts").child(thisBroadcastRequest.userid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("came inside first step")
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let thisBroadcast = MyBroadcast(dictionary: dictionary)
                        self.activityName.text = thisBroadcast.title!
                        Database.database().reference().child("users").child(thisBroadcastRequest.userid!).observeSingleEvent(of: .value, with: { (snapshot) in
                            //print("came inside first step")
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                let user = MyUser(dictionary: dictionary)
                                self.createdBy.text = user.name!
                            }
                            
                        }, withCancel: nil)
                        self.activityName.isHidden = false
                        self.createdBy.isHidden = false
                        self.status.isHidden = false
                        self.detailsBtn.isHidden = false
                        self.isMyCreated = false
                        self.noActivityHelpText.isHidden = true
                    }
                }, withCancel: nil)
            }
        }, withCancel: nil)
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
