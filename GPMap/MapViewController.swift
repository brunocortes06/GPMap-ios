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
import GeoFire

class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var Map: MKMapView!
    
    //    var users: Array<FIRDataSnapshot> = []
    var userHash = [String: User]()
    
    var uid:String = ""
    var lat:Double = 0.0
    var long:Double = 0.0
    var ref = FIRDatabase.database().reference()
    //    let user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        let geoFire = GeoFire(firebaseRef: ref.child("locations"))
        
        let center = CLLocation(latitude: lat, longitude: long)
        // Query locations with a radius of 100 km
//        print("center \(center)")
        let circleQuery = geoFire?.query(at: center, withRadius: 100)
        
        
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
//            self.getUserData(key: key!, location:location!)
        })
        
        circleQuery?.observeReady({
            //            print("All initial data has been loaded and events have been fired!")
        })
        
        let location = CLLocationCoordinate2DMake(lat, long)
//        let annotation = MKPointAnnotation()
//        
//        annotation.coordinate.longitude = location.longitude
//        annotation.coordinate.latitude = location.latitude
//        annotation.title = "teste"
//        annotation.subtitle = "testesub"
        
        self.Map.delegate = self
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long ))
        
        //Carregar foto de perfil
        point.image = UIImage(named: "girl-pin.png")
        point.name = "teste"
        point.address = "adress"
        point.phone = "phone"
//        self.mapView.addAnnotation(point)
        
        let span = MKCoordinateSpanMake(0.09, 0.09)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        Map.setRegion(region, animated: true)
        
        Map.addAnnotation(point)
//        Map.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = Map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
//        annotationView?.image = UIImage(named: "girl-pin")
        
        // Resize Pin image
        let pinImage = UIImage(named: "girl-pin")
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: size.width, height: size.height))
        pinImage!.draw(in: rect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.starbucksName.text = customAnnotation.name
        calloutView.starbucksAddress.text = customAnnotation.address
        calloutView.starbucksPhone.text = customAnnotation.phone
        calloutView.starbucksImage.image = customAnnotation.image
//        let button = UIButton(frame: calloutView.starbucksPhone.frame)
//        button.addTarget(self, action: #selector(ViewController.callPhoneNumber(sender:)), for: .touchUpInside)
//        calloutView.addSubview(button)
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
        
        
    }
    
//    func downloadImage(url: URL) {
//        print("Download Started")
//        getDataFromUrl(url: url) { (data, response, error)  in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() { () -> Void in
//                self.imageView.image = UIImage(data: data)
//            }
//        }
//    }
    
    func getUserData(key: String, location: CLLocation) /*-> Dictionary<String, User> */{
        ref.child("users").child(key).observe(.value, with: { (snapshot) in
            
            //            let key = (snapshot.key)
            
            let user = User(snapShot: snapshot)
            self.userHash[key] = user
            
            if(user.name != ""){
                
//                if let checkedUrl = URL(string: user.) {
//                    imageView.contentMode = .scaleAspectFit
//                    downloadImage(url: checkedUrl)
//                }
                
                let location = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate.longitude = location.longitude
                annotation.coordinate.latitude = location.latitude
                annotation.title = user.name
                annotation.subtitle = user.age
                
                //            let span = MKCoordinateSpanMake(0.09, 0.09)
                
                //            let region = MKCoordinateRegion(center: location, span: span)
                
                //            Map.setRegion(region, animated: true)
                
                
                self.Map.addAnnotation(annotation)
            }else{
//                print("key \(key)")
            }
            
        })
        //        return self.userHash
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
