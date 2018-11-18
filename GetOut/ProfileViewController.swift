//
//  ProfileViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var dp: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var myDescription: UITextView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        dp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        dp.isUserInteractionEnabled = true
        email.text = Auth.auth().currentUser?.email
        fetchUserProfile()
        fetchDP()
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        print("Close Button Clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateBtnClosed(_ sender: UIButton) {
        print("Update Button Clicked")
        //Auth.auth().currentUser?.setValue(name.text, forKey: "name")
        if Auth.auth().currentUser?.uid == nil {
            print("user id not found inside update function...")
        }
        else {
            registerUserIntoDatabaseWithUID(uid: (Auth.auth().currentUser?.uid)!)
            uploadImageToStorage()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIImagePickerController Delegates!!!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            dp.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUserProfile() {
        print("CAme to fetch user profile")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("value was nil man")
            //for some reason uid = nil
            return
        }
        // Read User information from DB
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print("came inside first step")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = MyUser(dictionary: dictionary)
                if user.name == nil {
                    print("username not found in db")
                }
                else {
                    print("YAHOOO NAME " + user.name!)
                    self.name.text = user.name!
                }
                if user.phone == nil {
                    print("userphone not found in db")
                }
                else {
                    print("YAHOOO PHONE " + user.phone!)
                    self.phone.text = user.phone!
                }
                if user.age == nil {
                    print("userage not found in db")
                }
                else {
                    print("YAHOOO AGE " + user.age!)
                    self.age.text = user.age!
                }
                if user.myDescription == nil {
                    print("userdescription not found in db")
                }
                else {
                    print("YAHOOO DESCRIPTION " + user.myDescription!)
                    self.myDescription.text = user.myDescription!
                }
                //self.setupProfileWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    private func fetchDP() {
        print("Fetch DP called...")
        let imageName = Auth.auth().currentUser!.uid
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
                    self.dp.image  = UIImage(data: data! as Data)
                }
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        let values = ["name": name.text, "phone": phone.text, "age": age.text, "myDescription": myDescription.text ] as [String : AnyObject]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
        })
    }
    
    private func uploadImageToStorage() {
        print("Came to upload image function")
        // upload profile image
        let imageName = Auth.auth().currentUser!.uid
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        // Compress Image into JPEG type
        if let profileImage = self.dp.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            _ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error when uploading profile image")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                //self.profileurl = metadata.downloadURL()?.absoluteString
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
