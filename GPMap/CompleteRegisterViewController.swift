//
//  CompleteRegisterViewController.swift
//  GPMap
//
//  Created by Bruno Cortes on 03/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit

class CompleteRegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var hairText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var skinText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var saveBton: UIButton!
    @IBOutlet weak var hairDropDown: UIPickerView!

    var data = [["Preto", "Loiro", "Ruivo", "Castanho"],["Branca", "Parda", "Negra", "Amarela"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hairDropDown.layer.backgroundColor = UIColor.white.cgColor
        hairDropDown.isHidden = true
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor

        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    @IBAction func saveRegister(_ sender: Any) {
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.count
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data[component].count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        self.view.endEditing(true)
        return data[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let item1 = data[0][pickerView.selectedRow(inComponent: 0)]
        let item2 = data[1][pickerView.selectedRow(inComponent: 1)]
        
        print("item1 antes \(item1)")
        if(!item1.isEmpty){
            print("item1 dps \(item1)")
            self.hairText.text = item1
        }
        
        if(!item2.isEmpty){
            print(item2)
            self.skinText.text = item2
        }
        

        
        
//        
//        self.hairText.text = self.data[row]
        self.hairDropDown.isHidden = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.hairText {
            self.hairDropDown.isHidden = false
            //if you dont want the users to se the keyboard type:
            
            textField.endEditing(true)
        }
    }

}
