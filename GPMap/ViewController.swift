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
    @IBOutlet weak var createAccBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    var long:Double = 0.0
    var lat:Double = 0.0
    let locationManager = CLLocationManager()
    var uid:String = ""
    var didFindLocation:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //         Background
        //        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            if(!didFindLocation){
                locationManager.requestLocation()
                if ((FIRAuth.auth()?.currentUser) != nil){
                    self.logoutBtn.alpha = 0.0
                    self.loginBtn.alpha = 0.0
                    self.emailField.alpha = 0.0
                    self.passField.alpha = 0.0
                    self.createAccBtn.alpha = 0.0
                    self.UserLabel.text = "Aguarde, determinando localização"
                }
            }
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didFindLocation = true
        
        //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //        print("locations = \(uid) \(locValue.latitude) \(locValue.longitude)")
        
        lat = manager.location!.coordinate.latitude
        long = manager.location!.coordinate.longitude
        
        locationManager.stopUpdatingLocation()
        
        
        
        //Se ja pegou a loclizacao e ja esta logado, chamar proxima segue
        if let user =  FIRAuth.auth()?.currentUser{
            self.logoutBtn.alpha = 1.0
            self.UserLabel.text = user.email
            uid = (FIRAuth.auth()?.currentUser?.uid)!
            // set da coordenada
            setLocation(coord: manager.location!)
            self.performSegue(withIdentifier: "ShowMap", sender: self)
        }else{
            self.logoutBtn.alpha = 0.0
            self.UserLabel.text = ""
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error on locationManager \(error)")
    }
    
    
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
                    
                    // set da coordenada
                    let coord = CLLocation(latitude: self.lat, longitude: self.long)
                    
                    self.setLocation(coord: coord)
                    
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
        if(FIRAuth.auth()?.currentUser?.uid != nil){
            let geofireRef = FIRDatabase.database().reference().child("locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            print(FIRAuth.auth()?.currentUser?.uid as Any)
            print(coord)
            geoFire?.setLocation(coord, forKey: FIRAuth.auth()?.currentUser?.uid)
        }
        //print("setGeoFire = \(coord) \(coord.coordinate.latitude) \(coord.coordinate.longitude)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
        self.view.window?.rootViewController = sw
        
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        let navigationController = UINavigationController(rootViewController: destinationController)
        
        sw.pushFrontViewController(navigationController, animated: true)
        destinationController.uid = uid
        destinationController.lat = lat
        destinationController.long = long
        
//        if segue.identifier == "ShowMap" {
        
//            let nav = segue.destination as! UINavigationController
//            let mapViewController = nav.topViewController as! MapViewController

            
//           antes da nav bar let mapViewController = (segue.destination as! MapViewController)
//            mapViewController.uid = uid
//            mapViewController.lat = lat
//            mapViewController.long = long
//        }
    }
    
}

