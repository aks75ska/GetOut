//
//  MyTabBarController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class MyTabBarController: UITabBarController, FUIAuthDelegate {
    
    var myLat : Double = 0
    var myLong : Double = 0
    
    var firstViewController = ViewController()
    var secondViewController = MyActivityViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        secondViewController = storyboard.instantiateViewController(withIdentifier: "MyActivityViewController1") as! MyActivityViewController
        
        // Do any additional setup after loading the view.
        firstViewController.tabBarItem = UITabBarItem(title: "Nearby Broadcasts", image:UIImage(named:"mapicon")?.withRenderingMode(UIImageRenderingMode.automatic), selectedImage: UIImage(named: "mapicon"))
        secondViewController.tabBarItem = UITabBarItem(title: "My Activity", image:UIImage(named:"mapicon")?.withRenderingMode(UIImageRenderingMode.automatic), selectedImage: UIImage(named: "mapicon"))
        let tabBarList = [firstViewController, secondViewController] as [Any]
        viewControllers = tabBarList as? [UIViewController]
        
        navigationItem.title = "GO!"
        
        // Do any additional setup after loading the view, typically from a nib.
        setupNavBar()
        //first we check if login is required, if yes we present the login/signup screen
        checkIfUserIsLoggedIn()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        callBackShouldBeThis()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavBar(){
        print ("Came inside setupNavBar")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(gotoProfile))
        //title view...
        // Create a navView to add to the navigation bar
        let navView = UIView()
        // Create the label
        let label = UILabel()
        label.text = "No User"
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        // Create the image view
        let image = UIImageView()
        image.image = UIImage(named: "currenticon")
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIViewContentMode.scaleAspectFit
        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)
        self.navigationItem.titleView = navView
    }
    
    @objc func gotoProfile() {
        print("Profile Button Clicked!")
        if Auth.auth().currentUser?.uid == nil {
            print("User Not Found...")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController1") as! ProfileViewController
            //navigationController?.pushViewController(vc, animated: true)
            navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func handleLogout() {
        // Sign-out!!!
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print("Could not log out!")
            print(logoutError)
        }
        // Show Login Screen Modally!!!
        //title view...
        // Create a navView to add to the navigation bar
        let navView = UIView()
        // Create the label
        let label = UILabel()
        label.text = "No User"
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        // Create the image view
        let image = UIImageView()
        image.image = UIImage(named: "currenticon")
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIViewContentMode.scaleAspectFit
        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)
        self.navigationItem.titleView = navView
        showLoginSignupScreen()
    }
    
    func checkIfUserIsLoggedIn() {
        print("Came inside checkIfUserIsLoggedIn")
        // if not sign in, display login screen!!!
        if Auth.auth().currentUser?.uid == nil {
            print("user not found")
            showLoginSignupScreen()
        } else {
            print("user found")
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        print("came inside fetchUserAndSetupNavBarTitle")
        if Auth.auth().currentUser?.uid == nil {
            print("Current user not found in nav controller...")
        } else {
            //title view...
            // Create a navView to add to the navigation bar
            let navView = UIView()
            // Create the label
            let label = UILabel()
            label.text = Auth.auth().currentUser?.email
            label.sizeToFit()
            label.center = navView.center
            label.textAlignment = NSTextAlignment.center
            // Create the image view
            let image = UIImageView()
            image.image = UIImage(named: "currenticon")
            
            //code for fetching user dp
            let imageName = Auth.auth().currentUser!.uid
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            // Fetch the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    print("some error occured in downloading image")
                } else {
                    print("Download image from url: " + String(describing: url!))
                    let data = NSData(contentsOf: url! as URL)
                    if data != nil {
                        image.image  = UIImage(data: data! as Data)
                    }
                }
            }
            
            // To maintain the image's aspect ratio:
            let imageAspect = image.image!.size.width/image.image!.size.height
            // Setting the image frame so that it's immediately before the text:
            image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
            image.contentMode = UIViewContentMode.scaleAspectFit
            // Add both the label and image view to the navView
            navView.addSubview(label)
            navView.addSubview(image)
            self.navigationItem.titleView = navView
        }
    }
    
    func showLoginSignupScreen()
    {
        print("came inside show signup screen...")
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        let authViewController = authUI!.authViewController()
        navigationController?.present(authViewController, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            print("YAHOO!!! User Logged in..."+email!)
            print("YAHOO!!! User Logged in..."+uid)
            if photoURL == nil
            {
                print("photo url was nil...")
            }
            else
            {
                print("YAHOO!!! User Logged in..."+String(describing: photoURL!))
                
            }
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func callBackShouldBeThis()
    {
        fetchUserAndSetupNavBarTitle()
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
