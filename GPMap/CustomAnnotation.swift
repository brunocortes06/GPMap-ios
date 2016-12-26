//
//  CustomAnnotation.swift
//  GPMap
//
//  Created by MAC MINI on 26/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var phone: String!
    var name: String!
    var address: String!
    var image: UIImage!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
