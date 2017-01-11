//
//  Message.swift
//  GPMap
//
//  Created by Bruno Cortes on 10/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
