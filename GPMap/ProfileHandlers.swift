//
//  ProfileHandlers.swift
//  GPMap
//
//  Created by Bruno Cortes on 04/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

let storageRef = FIRStorage.storage().reference()
let ref = FIRDatabase.database().reference()

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    
    func handleProfileImgView(){
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
        
        if let _ = profileImg.image, let uploadData =  UIImageJPEGRepresentation(profileImg.image!, 0.5){
        
//        if let uploadData = UIImagePNGRepresentation(profileImg.image!){
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                storageRef.child("photos").child(uid).child("profile.jpg").put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print("Erro no upload de imagem: \(error)")
                        return
                    }
                    self.ref.child("users").child(uid).child("photo").setValue(metadata?.downloadURL()?.absoluteString)
                })
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Seleção Cancelada")
        dismiss(animated: true, completion: nil)
    }
    
    
}
