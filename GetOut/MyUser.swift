//
//  MyUser.swift
//  GetOut
//
//  Created by Akshay Goyal on 4/24/18.
//  Copyright © 2018 Akshay Goyal. All rights reserved.
//

import UIKit

class MyUser: NSObject {
    var name: String?
    var phone: String?
    var age: String?
    var myDescription: String?
    
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.phone = dictionary["phone"] as? String
        self.age = dictionary["age"] as? String
        self.myDescription = dictionary["myDescription"] as? String
    }
}
