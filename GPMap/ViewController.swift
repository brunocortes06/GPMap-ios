//
//  ViewController.swift
//  GPMap
//
//  Created by MAC MINI on 15/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import GeoFire

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var logoutBtn: UIButton!
    
    let locationManager = CLLocationManager()
    var uid:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         Background
//        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if let user =  FIRAuth.auth()?.currentUser{
            self.logoutBtn.alpha = 1.0
            self.UserLabel.text = user.email
            uid = (FIRAuth.auth()?.currentUser?.uid)!
            
            self.performSegue(withIdentifier: "ShowMap", sender: self)
        }else{
            self.logoutBtn.alpha = 0.0
            self.UserLabel.text = ""
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        setLocation(coord: manager.location!)
    }
    
//    func locationManager(_ mager: CLLocationManager!, didFailWithError error: Error!){
//        
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func creteAccAction(_ sender: Any) {
        if self.emailField.text == "" || self.passField.text == ""{
            let alertcontroller = UIAlertController(title: "opa", message: "email ou senha em branco", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultAction)
            
            self.present(alertcontroller, animated: true, completion: nil)
        }else{
            FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.passField.text!, completion: { (user, error) in
                if error == nil {
                    self.logoutBtn.alpha = 1.0
                    self.UserLabel.text = user!.email
                    self.emailField.text = ""
                    self.passField.text = ""
                }else{
                    let alertcontroller = UIAlertController(title: "opa", message: error?.localizedDescription , preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alertcontroller.addAction(defaultAction)
                    
                    self.present(alertcontroller, animated: true, completion: nil)

                }
            })
        }
    }

    @IBAction func loginAction(_ sender: Any) {
        
        if self.emailField.text == "" || self.passField.text == ""{
            let alertcontroller = UIAlertController(title: "opa", message: "email ou senha em branco", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultAction)
            
            self.present(alertcontroller, animated: true, completion: nil)
        }else{
            FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passField.text!, completion: { (user, error) in
                if error == nil {
                    self.logoutBtn.alpha = 1.0
                    self.UserLabel.text = user!.email
                    self.emailField.text = ""
                    self.passField.text = ""
                    
                    self.performSegue(withIdentifier: "ShowMap", sender: self)
                }else{
                    let alertcontroller = UIAlertController(title: "opa", message: error?.localizedDescription , preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alertcontroller.addAction(defaultAction)
                    
                    self.present(alertcontroller, animated: true, completion: nil)
                    
                }
            })
        }
        
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        
        try! FIRAuth.auth()?.signOut()
        self.UserLabel.text = ""
        self.logoutBtn.alpha = 0.0
        self.emailField.text = ""
        self.passField.text = ""
        
        
    }
    
    func setLocation(coord: CLLocation){
        let geofireRef = FIRDatabase.database().reference().child("locations")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.setLocation(coord, forKey: FIRAuth.auth()?.currentUser?.uid)
        //print("setGeoFire = \(coord) \(coord.coordinate.latitude) \(coord.coordinate.longitude)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            let mapViewController = (segue.destination as! MapViewController)
            mapViewController.uid = uid
        }
    }
    
}

