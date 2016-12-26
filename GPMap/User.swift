//
//  User.swift
//  GPMap
//
//  Created by MAC MINI on 20/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct User {
//    User: NSObject {
    var name: String
    var age: String
    var gender: String
    var description: String
    var hair:String
    var skin:String
    var tel:String
    var photo:String
    
    init(name: String, age: String, gender: String, hair: String, skin: String, tel: String, description: String, photo: String) {
        self.name = name
        self.age = age
        self.gender = gender
        self.description = description
        self.hair = hair
        self.skin = skin
        self.tel = tel
        self.photo = photo
    }
    
    init(snapShot: FIRDataSnapshot){
        self.name = (snapShot.value as? NSDictionary)?["name"] as? String ?? ""
        self.age = (snapShot.value as? NSDictionary)?["age"] as? String ?? ""
        self.gender = (snapShot.value as? NSDictionary)?["gender"] as? String ?? ""
        self.description = (snapShot.value as? NSDictionary)?["description"] as? String ?? ""
        self.hair = (snapShot.value as? NSDictionary)?["hair"] as? String ?? ""
        self.skin = (snapShot.value as? NSDictionary)?["skin"] as? String ?? ""
        self.tel = (snapShot.value as? NSDictionary)?["name"] as? String ?? ""
        self.photo = (snapShot.value as? NSDictionary)?["photo"] as? String ?? ""
        
//        self.name = ((snapShot.value! as! NSDictionary)["name"] as! String)
//        self.age = ((snapShot.value! as! NSDictionary)["age"] as! String)
//        self.gender = ((snapShot.value! as! NSDictionary)["gender"] as! String)
//        self.description = ((snapShot.value! as! NSDictionary)["description"] as! String)
//        self.hair = ((snapShot.value as! NSDictionary)["hair"] as! String)
//        self.skin = ((snapShot.value! as! NSDictionary)["skin"] as! String)
//        self.tel = ((snapShot.value! as! NSDictionary)["tel"] as! String)
        
    }
    
    func toAnyObject() -> [String: Any]{
        return ["name": name, "age": age, "gender": gender, "description": description, "hair": hair, "skin": skin, "tel": tel, "photo": photo]
    }
    
//    init() {
//        self.init(name: "", age: "", gender: "",  hair: "", skin: "", tel: "", description: "")
//    }
    
}
