//
//  ViewController.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseAuthUI

extension UIImage{
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //Lat Long for SU are: 43.04044009999999, -76.13323539999999
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    var broadcasts = [MyBroadcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: 0,
                                              longitude: 0,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        mapView.delegate = self
        
        //************
        /*let markerView = UIView()
        let label = UILabel()
        label.text = "asdasdasd"
        label.sizeToFit()
        label.center = markerView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "currenticon")
        let imageAspect = image.image!.size.width/image.image!.size.height
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIViewContentMode.scaleAspectFit
        // Add both the label and image view to the navView
        markerView.addSubview(label)
        markerView.addSubview(image)
        var myim = UIImage.init(view: markerView)*/
        //************
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getBroadcastsFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tap marker event
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker Tapped: " + marker.title!)
        if Auth.auth().currentUser?.uid == nil {
            print("User Not Found...")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SomeBroadcastViewController1") as! SomeBroadcastViewController
            vc.creatorUserId = marker.title!
            navigationController?.pushViewController(vc, animated: true)
            //navigationController?.present(vc, animated: true, completion: nil)
        }
        return true
    }
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("came inside loc update")
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        //mapView.clear()
        // Add a marker to the map.
        
        /*let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.title = "user id 1"
        marker.snippet = "My Description"*/
        
        let myTab = self.tabBarController as! MyTabBarController
        myTab.myLat = location.coordinate.latitude
        myTab.myLong = location.coordinate.longitude

        /*let markerView = UIView()
        let label = UILabel()
        label.text = "Label Text"
        label.sizeToFit()
        label.center = markerView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "currenticon")
        let imageAspect = image.image!.size.width/image.image!.size.height
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIViewContentMode.scaleAspectFit
        // Add both the label and image view to the navView
        markerView.addSubview(label)
        markerView.addSubview(image)*/
        
        //marker.iconView = markerView
        //marker.icon = imageWithView(view: markerView)
        
        //marker.map = mapView
        
        //testing code
        /*let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: 43.045, longitude: -76.135)
        marker2.title = "user id 2"
        marker2.snippet = "My Description 2"
        marker2.map = mapView*/
        //populateOtherMarkers here
        
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("came inside loc auth")
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("came inside loc error")
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    /*func getBroadcastsAndAddMarkers()
    {
        getBroadcastsFromDB {
            print("getBroadcastsFromDB call completed")
            //Now we will clear all markers and add new ones
            //self.mapView.clear()
            for oneBroadcast in self.broadcasts {
                print("came to add markers....")
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: oneBroadcast.lat!, longitude: oneBroadcast.long!)
                marker.title = oneBroadcast.userid
                marker.snippet = oneBroadcast.userid
                marker.map = self.mapView
            }
        }
    }*/
    
    func getBroadcastsFromDB()
    {
        print("Came inside getBroadcastsFromDB")
        self.broadcasts.removeAll()
        self.mapView.clear()
        // Read Broadcast information from DB
        let ref = Database.database().reference().child("broadcasts")
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            for snap in snapshot.children {
                var useridforthisbroadcast = (snap as! DataSnapshot).key
                print(useridforthisbroadcast)
                print("came inside for loop inside ref observe..")
                if Auth.auth().currentUser?.uid == nil {
                    print("user id not found inside getBroadcastsFromDB function...")
                }
                else {
                        if useridforthisbroadcast != Auth.auth().currentUser?.uid {
                            if let dictionary = (snap as! DataSnapshot).value as! [String:Any]?
                            {
                                //print (dictionary)
                                var thisbroadcast = MyBroadcast(dictionary: dictionary as [String : AnyObject])
                                thisbroadcast.userid = useridforthisbroadcast
                                self.broadcasts.append(thisbroadcast)
                                print("broadcast appended...")
                                print(thisbroadcast.userid!)
                                //now add a marker
                                //************
                                let markerView = UIView()
                                let label = UILabel()
                                label.text = thisbroadcast.title!
                                label.sizeToFit()
                                label.center = markerView.center
                                label.textAlignment = NSTextAlignment.center
                                let image = UIImageView()
                                image.image = UIImage(named: "currenticon")
                                let imageAspect = image.image!.size.width/image.image!.size.height
                                image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect-5, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
                                image.contentMode = UIViewContentMode.scaleAspectFit
                                // Add both the label and image view to the navView
                                markerView.addSubview(label)
                                markerView.addSubview(image)
                                //************
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: thisbroadcast.lat!, longitude: thisbroadcast.long!)
                                marker.title = thisbroadcast.userid
                                marker.snippet = thisbroadcast.userid
                                
                                //marker.iconView = markerView
                                //marker.icon = self.imageWithView(view: markerView)
                                //marker.icon = UIImage.init(view: markerView)
                                marker.map = self.mapView
                            }
                    }
                }
            }
        }, withCancel: nil)
    }

}

