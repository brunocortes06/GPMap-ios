//
//  ProfileViewController.swift
//  GPMap
//
//  Created by Bruno Cortes on 04/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var ref = FIRDatabase.database().reference()
    var uid: String = ""
    
    let profileImg = UIImageView()
    var userSnap = FIRDataSnapshot()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.setTitle("Editar", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleEditSaveAction), for: .touchUpInside)
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
    
    let ageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Idade"
        tf.keyboardType = UIKeyboardType.numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let ageSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let telTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Telefone"
        tf.keyboardType = UIKeyboardType.phonePad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let descTextView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1
        view.placeholderText = "Descrição"
        view.text = "Descricao..."
//        view.textColor = UIColor.lightGray
        view.font = UIFont.systemFont(ofSize: 18)
        view.layer.borderColor = UIColor.black.cgColor
        view.isEditable = true
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            self.revealViewController().delegate = self
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        profileImg.image = UIImage(named: "no-user-image")
        profileImg.translatesAutoresizingMaskIntoConstraints = false
        profileImg.layer.cornerRadius = 15
        profileImg.layer.masksToBounds = true
        profileImg.contentMode = .scaleAspectFill
        profileImg.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleProfileImgView))
        profileImg.addGestureRecognizer(tapRecognizer)

        
        self.uid = (FIRAuth.auth()?.currentUser?.uid)!
        
        ageTextField.isEnabled = false
        nameTextField.isEnabled = false
        descTextView.isEditable = false
        
        descTextView.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        view.addSubview(inputsContainerView)
        view.addSubview(editButton)
        view.addSubview(descTextView)
        view.addSubview(profileImg)
        
        setInputsContainerView()
        setProfileImgView()
        
        getProfilePhoto(uid:uid)

    }
    

    func setInputsContainerView(){
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editButton.topAnchor.constraint(equalTo: descTextView.bottomAnchor, constant: 12).isActive = true
        editButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputsContainerView.addSubview(nameSeparatorView)
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(ageTextField)
        
        ageTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        ageTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        ageTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        ageTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        inputsContainerView.addSubview(ageSeparatorView)
        
        ageSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        ageSeparatorView.topAnchor.constraint(equalTo: ageTextField.bottomAnchor).isActive = true
        ageSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        ageSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(telTextField)
        
        telTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        telTextField.topAnchor.constraint(equalTo: ageSeparatorView.bottomAnchor).isActive = true
        telTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        telTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        descTextView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        descTextView.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        descTextView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        descTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    func setProfileImgView(){
        profileImg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImg.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -15).isActive = true
        profileImg.widthAnchor.constraint(equalToConstant: 180).isActive = true
        profileImg.heightAnchor.constraint(equalToConstant: 180).isActive = true
    }
    
    func getProfilePhoto(uid: String){
        ref.child("users").child(uid).observe(.value, with: { (snapshot) in
            
            self.userSnap = snapshot
            
            let user = User(snapShot: snapshot)
            
            if(!user.name.isEmpty){
                self.nameTextField.text = user.name
            }
            
            if(!user.age.isEmpty){
                self.ageTextField.text = user.age
            }
            
            if(!user.description.isEmpty){
                self.descTextView.text = user.description
            }
            
                var url = URL(string: "")
                if(user.photo != ""){
                    url = URL(string: user.photo)
                     self.profileImg.loadImgUsingCache(url: url!)
                }
            
        })
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        descTextView.text = ""
    }
    
    func handleEditSaveAction(){
        ageTextField.isEnabled = true
        nameTextField.isEnabled = true
        descTextView.isEditable = true
        
        editButton.setTitle("Salvar", for: .normal)
        
        if(ageTextField.text == "" || nameTextField.text == "" || descTextView.text == "Descricao..."){
            let alertcontroller = UIAlertController(title: "Erro", message: "Preencha os campos antes de salvar", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultAction)
            self.present(alertcontroller, animated: true, completion: nil)
        }else{
            //sets
            var user = User(snapShot: self.userSnap)
            user.age = self.ageTextField.text!
            user.name = self.nameTextField.text!
            user.description = self.descTextView.text!
            self.ref.child("users").child(uid).updateChildValues(user.toAnyObject())
        }
        
    }
    
    
    
    
    
}
