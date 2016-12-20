//
//  MapViewController.swift
//  GPMap
//
//  Created by MAC MINI on 17/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController {

    @IBOutlet weak var Map: MKMapView!
    
    var uid:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var ref = FIRDatabase.database().reference()
        
        print("uid = \(uid)")
        
        let location = CLLocationCoordinate2DMake(-23.464636666666667,-46.538509999999995)
        let annotation = MKPointAnnotation()
    
        annotation.coordinate.longitude = -46.538509999999995
        annotation.coordinate.latitude = -23.464636666666667
        annotation.title = "teste"
        annotation.subtitle = "testesub"
        
        let span = MKCoordinateSpanMake(0.09, 0.09)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        Map.setRegion(region, animated: true)
        
        
        Map.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
 
        
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
