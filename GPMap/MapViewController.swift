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

class MapViewController: UIViewController, MKMapViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var Map: MKMapView!
    
//    var userHash = [String: User]()
    let noPhoto:String = "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac"
    var uid:String = ""
    var lat:Double = 0.0
    var long:Double = 0.0
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            self.revealViewController().delegate = self
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Do any additional setup after loading the view.
        
        
        let geoFire = GeoFire(firebaseRef: ref.child("locations"))
        
        let center = CLLocation(latitude: lat, longitude: long)
        // Query locations with a radius of 100 km
//        print("center \(center)")
        let circleQuery = geoFire?.query(at: center, withRadius: 100)
        
        
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            self.getUserData(key: key!, location:location!)
        })
        
        circleQuery?.observeReady({
            //            print("All initial data has been loaded and events have been fired!")
        })
        
        let location = CLLocationCoordinate2DMake(lat, long)

        self.Map.delegate = self
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long ))
        
        //Carregar foto de perfil
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac")
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        point.image = UIImage(data: data!)
//        point.image = UIImage(named: "girl-pin.png")
        point.name = "teste"
        point.address = "adress"
        point.phone = "phone"
        
        let span = MKCoordinateSpanMake(0.09, 0.09)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        Map.setRegion(region, animated: true)
        
        Map.addAnnotation(point)
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
        
        let button = UIButton(frame: calloutView.starbucksPhone.frame)
        button.addTarget(self, action: #selector(self.callPhoneNumber(sender:)), for: .touchUpInside)
        calloutView.addSubview(button)
        
        calloutView.starbucksImage.image = customAnnotation.image
        
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
    
    func getUserData(key: String, location: CLLocation) /*-> Dictionary<String, User> */{
        ref.child("users").child(key).observe(.value, with: { (snapshot) in

            let user = User(snapShot: snapshot)
//            self.userHash[key] = user
            
            if(user.name != ""){
                var url = URL(string: "")
                if(user.photo != ""){
                    url = URL(string: user.photo)
                }else{
                    url = URL(string: self.noPhoto)
                }
                

//                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude ))
                
                //Carrego a imagem do cache
                point.loadImgUsingCache(url: url!)
                
                let userLocation = CLLocation(latitude: self.lat, longitude: self.long)
                let otherUser = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                
                let distanceInKm = (userLocation.distance(from: otherUser))/1000 // result is in meters
                point.name = user.name
                point.address = "Distância: \(round(distanceInKm)) Km"
                point.phone = user.tel

                self.Map.addAnnotation(point)
//            }else{
//                print("key \(key)")
            }
            
        })
    }
    
    func callPhoneNumber(sender: UIButton)
    {
        let v = sender.superview as! CustomCalloutView
        if let url = URL(string: "telprompt://\(v.starbucksPhone.text!)"), UIApplication.shared.canOpenURL(url)
        {
//            UIApplication.shared.openURL( url)
            let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
            UIApplication.shared.open(url, options: options, completionHandler: nil)
        }
    }
    
}
