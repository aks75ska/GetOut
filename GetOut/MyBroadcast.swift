//
//  MyBroadcast.swift
//  GetOut
//
//  Created by Akshay Goyal on 5/4/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit

class MyBroadcast: NSObject {
    var lat: Double?
    var long: Double?
    var title: String?
    var mydescription: String?
    var userid: String?
    
    init(dictionary: [String: AnyObject]) {
        self.lat = dictionary["latitude"] as? Double
        self.long = dictionary["longitude"] as? Double
        self.title = dictionary["title"] as? String
        self.mydescription = dictionary["description"] as? String
    }
}

class RequestForBroadcast: NSObject {
    var status: String?
    var userid: String?
    var rname: String?
    var rage: String?
    
    init(dictionary: [String: AnyObject]) {
        self.status = dictionary["status"] as? String
        self.userid = dictionary["broadcasterid"] as? String
    }
}
