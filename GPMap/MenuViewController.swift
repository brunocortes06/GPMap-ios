//
//  MenuViewController.swift
//  GPMap
//
//  Created by MAC MINI on 27/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var menuNameArr:Array = [String]()
    var iconeImage:Array = [UIImage]()
    @IBOutlet weak var imgProfile: UIImageView!
    
    let noPhoto:String = "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac"
    var long:Double = 0.0
    var lat:Double = 0.0
    let locationManager = CLLocationManager()
    var uid:String = ""
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            getProfilePhoto(uid: uid)
        }
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestLocation()
        }
        
        menuNameArr = ["Mapa","Carregar foto", "Sair"]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        //        cell.imgIcon.image = iconeImage[indexPath.row]
        cell.lblMenuName.text! = menuNameArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewCOntroller:SWRevealViewController = self.revealViewController()
        let cell:MenuTableViewCell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        
        if cell.lblMenuName.text == "Sair"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            try! FIRAuth.auth()?.signOut()
            revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenuName.text == "Mapa"{
            if(lat != 0.0){
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let desController = mainStoryboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let newFrontViewController = UINavigationController.init(rootViewController:desController)
                desController.lat = lat
                desController.long = long
                desController.uid = uid
                revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
            }else{
                let alertcontroller = UIAlertController(title: "Aguarde", message: "Atualizando localização", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertcontroller.addAction(defaultAction)
                self.present(alertcontroller, animated: true, completion: nil)
                
            }
        }
        
        if cell.lblMenuName.text == "Carregar foto"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ProfilePhotoViewController") as! ProfilePhotoViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lat = manager.location!.coordinate.latitude
        long = manager.location!.coordinate.longitude
        
        locationManager.stopUpdatingLocation()
        
        //Se ja pegou a loclizacao, pegar o uid do usuario para carregar perfil
        if (FIRAuth.auth()?.currentUser) != nil{
            uid = (FIRAuth.auth()?.currentUser?.uid)!
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error on locationManager \(error)")
    }
    
    func getProfilePhoto(uid: String){
        ref.child("users").child(uid).observe(.value, with: { (snapshot) in
            
            let user = User(snapShot: snapshot)
            
            if(user.name != ""){
                var url = URL(string: "")
                if(user.photo != ""){
                    url = URL(string: user.photo)
                }else{
                    url = URL(string: self.noPhoto)
                }
                 self.imgProfile?.loadImgUsingCache(url: url!)
                
//                DispatchQueue.global().async {
//                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    DispatchQueue.main.async {
//                        let pinImage = UIImage(data: data!)
//                        let size = CGSize(width: 143, height: 128)
//                        UIGraphicsBeginImageContext(size)
//                        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: size.width, height: size.height))
//                        pinImage!.draw(in: rect)
//                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//                        UIGraphicsEndImageContext()
//                        self.imgProfile?.image = resizedImage
//                        self.imgProfile?.layer.cornerRadius = 20
//                        self.imgProfile?.layer.masksToBounds = true
//                    }
//                }
            }
            
        })
    }
}
