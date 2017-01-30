//
//  ProfilePhotoViewController.swift
//  GPMap
//
//  Created by MAC MINI on 28/12/16.
//  Copyright © 2016 Change Logic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    
    let storage = FIRStorage.storage()
    let storageRef = FIRStorage.storage().reference().child("photos")
    let ref = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectPhotoAct(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImgFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImgFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImgFromPicker = originalImage
        }
        
        if let selectedImg = selectedImgFromPicker{
            profileImg.image = selectedImg
        }
        dismiss(animated: true, completion: nil)
        
        if let uploadData = UIImagePNGRepresentation(profileImg.image!){
            if let uid = FIRAuth.auth()?.currentUser?.uid {
//                storageRef.child(uid).put(uploadData)
                storageRef.child(uid).child("profile.png").put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error?.localizedDescription as Any)
                        return
                    }
                    print("uid funciona \(uid)")
                    self.ref.child(uid).child("photo").setValue(metadata?.downloadURL()?.absoluteString)
                })
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Seleção Cancelada")
        dismiss(animated: true, completion: nil)
    }
    
}
