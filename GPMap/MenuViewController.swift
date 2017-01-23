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
import FBSDKLoginKit

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().frontViewController.revealViewController().tapGestureRecognizer()
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = true
    }
    
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
        
        menuNameArr = ["Perfil", "Mapa", "Mensagens", "Termos de uso", "Sair"] //"Carregar foto"
        iconeImage = [UIImage(named: "profile_icon")!,UIImage(named: "map_icon")!,UIImage(named: "message_icon")!, UIImage(named: "eula-icon")!, UIImage(named: "exit_icon")!]
        
//        menuNameArr = ["Perfil", "Mapa", "Mensagens", "Termos de uso", "Usuários bloqueados", "Sair"] //"Carregar foto"
//        iconeImage = [UIImage(named: "profile_icon")!,UIImage(named: "map_icon")!,UIImage(named: "message_icon")!, UIImage(named: "eula-icon")!, UIImage(named: "exit_icon")!, UIImage(named: "block-icon")!]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        cell.imgIcon.image = iconeImage[indexPath.row]
        cell.lblMenuName.text! = menuNameArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let revealViewCOntroller:SWRevealViewController = self.revealViewController()
        let cell:MenuTableViewCell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        
        if cell.lblMenuName.text == "Sair"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "MasterLoginViewController") as! LoginViewController
            //            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            try! FIRAuth.auth()?.signOut()
            let manager = FBSDKLoginManager()
            manager.logOut()
            revealViewCOntroller.pushFrontViewController(desController, animated: true)
            desController.logout = true
        }
        
        if cell.lblMenuName.text == "Mensagens"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            
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
        
        //        if cell.lblMenuName.text == "Carregar foto"{
        //            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ProfilePhotoViewController") as! ProfilePhotoViewController
        //            let newFrontViewController = UINavigationController.init(rootViewController:desController)
        //            revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        //        }
        
        if cell.lblMenuName.text == "Perfil"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenuName.text == "Usuários bloqueados"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "BlockedUsersController") as! BlockedUsersController
            let newFrontViewController = UINavigationController.init(rootViewController:desController)
            revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenuName.text == "Termos de uso"{
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "https://sites.google.com/view/eula/")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: "https://sites.google.com/view/eula/")!)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if ( manager.location != nil) {
            lat = manager.location!.coordinate.latitude
            long = manager.location!.coordinate.longitude
            
            //Se ja pegou a loclizacao, pegar o uid do usuario para carregar perfil
            if (FIRAuth.auth()?.currentUser) != nil{
                locationManager.stopUpdatingLocation()
                uid = (FIRAuth.auth()?.currentUser?.uid)!
            }
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
