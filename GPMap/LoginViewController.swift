//
//  LoginViewController.swift
//  GPMap
//
//  Created by MAC MINI on 29/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import GeoFire

class LoginViewController: UIViewController, UIPickerViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    var name:String = ""
    var age:String = ""
    var gender:String = "Masculino"
    var long:Double = 0.0
    var lat:Double = 0.0
    let locationManager = CLLocationManager()
    var logout:Bool = false
    
    var ref: FIRDatabaseReference!
    
    let loadLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.isHidden = true
        label.textAlignment = NSTextAlignment.center
        label.text = "Aguarde determinando localização"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    let logoImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "coracao_gpmap")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.setTitle("Cadastrar", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegisterAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nome"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-mail"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Senha"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let genderControl: UISegmentedControl = {
        let gender = UISegmentedControl(items:["Masculino","Feminino"])
        gender.tintColor = UIColor.white
        gender.selectedSegmentIndex = 0
        gender.layer.cornerRadius = 5
        gender.layer.masksToBounds = true
        gender.addTarget(self, action: #selector(handleGenderChange), for: .valueChanged)
        gender.translatesAutoresizingMaskIntoConstraints = false
        return gender
    }()
    
    let loginRegisterControl: UISegmentedControl = {
        let lr = UISegmentedControl(items: ["Entrar", "Cadastrar"])
        lr.tintColor = UIColor.white
        lr.selectedSegmentIndex = 1
        lr.layer.cornerRadius = 5
        lr.layer.masksToBounds = true
        lr.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        lr.translatesAutoresizingMaskIntoConstraints = false
        return lr
    }()
    
    let datePicker: UIDatePicker = {
        let dtPicker = UIDatePicker()
        
        dtPicker.datePickerMode = UIDatePickerMode.date
        dtPicker.timeZone = NSTimeZone.local
        dtPicker.backgroundColor = UIColor.white
        dtPicker.layer.cornerRadius = 5
        dtPicker.layer.masksToBounds = true
        dtPicker.addTarget(self, action: #selector(LoginViewController.datePickerValueChanged(_:)), for: .valueChanged)
        dtPicker.translatesAutoresizingMaskIntoConstraints = false
        return dtPicker
    }()
    
    func handleLoginRegisterAction(){
        
        //Login
        if loginRegisterControl.selectedSegmentIndex == 0 {
            if emailTextField.text == nil{
                let alertcontroller = UIAlertController(title: "Erro", message: "O e-mail deve ser preenchido", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertcontroller.addAction(defaultAction)
                self.present(alertcontroller, animated: true, completion: nil)
            }
            if passwordTextField.text == nil{
                let alertcontroller = UIAlertController(title: "Erro", message: "O nome precisa ser preenchido", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertcontroller.addAction(defaultAction)
                self.present(alertcontroller, animated: true, completion: nil)
            }
            
            if(passwordTextField.text != nil && emailTextField.text != nil){
                FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                    if error == nil {
                        
                        if(self.lat == 0.0){
                            self.locationManager.requestLocation()
                        }else{
                        // set da coordenada
                        let coord = CLLocation(latitude: self.lat, longitude: self.long)
                        
                        self.setLocation(coord: coord)
                        
                        self.performSegue(withIdentifier: "ShowMap1", sender: self)
                        }
                    }else{
                        let alertcontroller = UIAlertController(title: "Erro", message: error?.localizedDescription , preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertcontroller.addAction(defaultAction)
                        
                        self.present(alertcontroller, animated: true, completion: nil)
                        
                    }
                })
            }
            
            
            //Cadastro
        }else{
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil {
                    let user = User.init(name: self.nameTextField.text!, age: String(self.age), gender: self.gender, hair: "", skin: "", tel: "", description: "", photo: "")
                    self.ref = FIRDatabase.database().reference()
                    self.ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(user.toAnyObject())
                    
                    // set da coordenada
                    let coord = CLLocation(latitude: self.lat, longitude: self.long)
                    
                    self.setLocation(coord: coord)
                    
                    self.performSegue(withIdentifier: "ShowMap1", sender: self)
                    
                }else{
                    let alertcontroller = UIAlertController(title: "Erro", message: error?.localizedDescription , preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alertcontroller.addAction(defaultAction)
                    
                    self.present(alertcontroller, animated: true, completion: nil)
                    
                }
            })
            
        }
        
    }
    
    
    
    func setLocation(coord: CLLocation){
        if(FIRAuth.auth()?.currentUser?.uid != nil){
            let geofireRef = FIRDatabase.database().reference().child("locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire?.setLocation(coord, forKey: FIRAuth.auth()?.currentUser?.uid)
        }
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        let today = NSDate()
        
        let dateOfBirth = datePicker.date
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        if let age = gregorian.components([.year], from: dateOfBirth, to: today as Date, options: []).year {
            
            let ageInt = age
            self.age = String(ageInt)
        }
    }
    
    func handleGenderChange(){
        
        let title = genderControl.titleForSegment(at: genderControl.selectedSegmentIndex)
        self.gender = String(title!)
        
    }
    
    func handleLoginRegisterChange(){
        
        let title = loginRegisterControl.titleForSegment(at: loginRegisterControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputsContainerViewHeightAnchor?.constant = loginRegisterControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextField.isHidden = loginRegisterControl.selectedSegmentIndex == 0 ? true : false
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        datePicker.isHidden = loginRegisterControl.selectedSegmentIndex ==  0 ? true : false
        genderControl.isHidden = loginRegisterControl.selectedSegmentIndex ==  0 ? true : false
        
        loginButtonTopAnchor?.isActive = false
        loginButtonTopAnchor = loginRegisterButton.topAnchor.constraint(equalTo: loginRegisterControl.selectedSegmentIndex ==  0 ? inputsContainerView.bottomAnchor : datePicker.bottomAnchor, constant: 12 )
        loginButtonTopAnchor?.isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterControl)
        view.addSubview(loginRegisterButton)
        view.addSubview(genderControl)
        view.addSubview(datePicker)
        view.addSubview(logoImg)
        view.addSubview(loadLabel)

        setInputsContainerView()
        setLoginRegisterControl()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
            if ((FIRAuth.auth()?.currentUser) != nil){
                loadingLogin()
            }
        }
    }
    
    func loadingLogin(){
        // Se esta logado escondo os campos e centralizo o logo e texto pedindo para aguardar
        inputsContainerView.isHidden = true
        loginRegisterControl.isHidden = true
        genderControl.isHidden = true
        datePicker.isHidden = true
        loginRegisterButton.isHidden = true
        loadLabel.isHidden = false
        
        loadLabelTopAnchor = loadLabel.topAnchor.constraint(equalTo: logoImg.bottomAnchor, constant: 12 )
        loginButtonTopAnchor?.isActive = true
        
        logoImgYAnchor = logoImg.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -12 )
        logoImgYAnchor?.isActive = true
    }
    
    func setLoginRegisterControl(){
        
        genderControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        genderControl.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor,constant: 12).isActive = true
        genderControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        genderControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: genderControl.bottomAnchor,constant: 12).isActive = true
        datePicker.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginRegisterControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var loginButtonTopAnchor: NSLayoutConstraint?
    var loadLabelTopAnchor: NSLayoutConstraint?
    var logoImgYAnchor: NSLayoutConstraint?
    
    func setInputsContainerView(){
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        logoImg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImgYAnchor = logoImg.bottomAnchor.constraint(equalTo: loginRegisterControl.topAnchor, constant: -12)
            logoImgYAnchor?.isActive = true
        
        loadLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -12).isActive = true
        loadLabelTopAnchor = loadLabel.topAnchor.constraint(equalTo: logoImg.bottomAnchor, constant: 12)
            loadLabelTopAnchor?.isActive = true
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButtonTopAnchor = loginRegisterButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 12)
            loginButtonTopAnchor?.isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameSeparatorView)
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(emailSeparatorView)
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        inputsContainerView.addSubview(passwordTextField)
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(passwordSeparatorView)
        
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lat = manager.location!.coordinate.latitude
        long = manager.location!.coordinate.longitude
        
        print("\(lat) \(long)")

        
        //Se ja pegou a loclizacao e ja esta logado, chamar proxima segue
        if (FIRAuth.auth()?.currentUser) != nil{
            locationManager.stopUpdatingLocation()
            // set da coordenada
            setLocation(coord: manager.location!)
            self.performSegue(withIdentifier: "ShowMap1", sender: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error on locationManager \(error)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
        self.view.window?.rootViewController = sw
        
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        let navigationController = UINavigationController(rootViewController: destinationController)
        
        sw.pushFrontViewController(navigationController, animated: true)
        destinationController.lat = lat
        destinationController.long = long
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
