//
//  CreateEditBroadcastViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/25/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class CreateEditBroadcastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var requests = [RequestForBroadcast]()
    
    var myLat : Double = 0
    var myLong : Double = 0
    
    @IBOutlet weak var ceBroadcastTitle: UITextField!
    @IBOutlet weak var ceBroadcastDescription: UITextView!
    @IBOutlet weak var ceRequestsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ceRequestsTable.register(UITableViewCell.self, forCellReuseIdentifier: "requestcell")
        ceRequestsTable.dataSource = self
        ceRequestsTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getBroadcastDetailsFromDB()
        populateTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        print("Close Button Clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateBtnClicked(_ sender: UIButton) {
        print("Update Button Clicked")
        if Auth.auth().currentUser?.uid == nil {
            print("user id not found inside update function...")
        }
        else {
            registerBroadcastIntoDatabase()
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func ceDeleteBtnClicked(_ sender: UIButton) {
        print("delete btn clicked")
        let ref = Database.database().reference()
        for oneRequest in self.requests {
            let requestReference = ref.child("individualrequests").child(oneRequest.userid!)
            requestReference.removeValue()
        }
        let requestReference = ref.child("broadcasts").child((Auth.auth().currentUser?.uid)!)
        requestReference.removeValue()
        navigationController?.popViewController(animated: true)
    }
    
    private func registerBroadcastIntoDatabase() {
        let userid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let broadcastReference = ref.child("broadcasts").child(userid!)
        
        let values = ["latitude": myLat, "longitude": myLong, "title": ceBroadcastTitle.text ?? "Default Title", "description": ceBroadcastDescription.text ?? "Default Description" ] as [String : AnyObject]
        
        broadcastReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print ("some error in writing broadcast to db...")
                print(err ?? "")
                return
            }
        })
    }
    
    func getBroadcastDetailsFromDB()
    {
        print("Came inside getBroadcastDetailsFromDB")
        // Read Broadcast information from DB
        Database.database().reference().child("broadcasts").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let thisBroadcast = MyBroadcast(dictionary: dictionary)
                self.ceBroadcastTitle.text = thisBroadcast.title!
                self.ceBroadcastDescription.text = thisBroadcast.mydescription!
            }
        }, withCancel: nil)
    }
    
    func populateTable()
    {
        print("Came inside Populate Request Table")
        self.requests.removeAll()
        // Read Request information from DB
        let ref = Database.database().reference().child("broadcasts").child((Auth.auth().currentUser?.uid)!).child("requests")
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                var useridforthisrequest = (snap as! DataSnapshot).key
                print(useridforthisrequest)
                print("came inside for loop inside ref observe..")
                if let dictionary = (snap as! DataSnapshot).value as! [String:Any]?
                {
                    //print (dictionary)
                    var thisrequest = RequestForBroadcast(dictionary: dictionary as [String : AnyObject])
                    thisrequest.userid = useridforthisrequest
                    print("useridforthisrequest + " + useridforthisrequest)
                    Database.database().reference().child("users").child(useridforthisrequest).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            print("ASSIGING RNAME AND RAGE")
                            let user = MyUser(dictionary: dictionary)
                            print(user.name!)
                            print(user.age!)
                            thisrequest.rname = user.name!
                            thisrequest.rage = user.age!
                            self.requests.append(thisrequest)
                            print("request appended...")
                            print(thisrequest.userid!)
                            self.ceRequestsTable.reloadData()
                        }
                    }, withCancel: nil)
                }
            }
        })
    }
    
    //table view delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicked a row...\n")
        print("Num: \(indexPath.row)")
        let request = self.requests[indexPath.row]
        //now open the request page...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RequestViewController1") as! RequestViewController
        vc.userid = request.userid!
        self.navigationController?.present(vc, animated: true, completion: nil)
        print("completed call")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("request count is: " + String(self.requests.count) )
        return self.requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
                return UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "requestcell")
            }
            return cell
        }()
        var detailText = "Status: "
        if self.requests[indexPath.row].status == "R" {
            detailText = detailText + "Rejected"
        }
        else if self.requests[indexPath.row].status == "A" {
            detailText = detailText + "Accepted"
        }
        else if self.requests[indexPath.row].status == "P" {
            detailText = detailText + "Pending"
        }
        cell.textLabel!.text = self.requests[indexPath.row].rname! + ", " + self.requests[indexPath.row].rage!
        cell.detailTextLabel!.text = detailText
        //cell.textLabel!.text = "Akshay"
        //cell.detailTextLabel!.text = "details lol"
        return cell
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
