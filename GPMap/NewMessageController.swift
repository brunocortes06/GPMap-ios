//
//  NewMessageController.swift
//  GPMap
//
//  Created by Bruno Cortes on 10/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    let cellId = "cellId"
    
    let noPhoto:String = "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if self.revealViewController() != nil {
//            menuBtn.target = self.revealViewController()
//            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
//            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                var user = User(snapShot: snapshot)
                user.id = snapshot.key
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
//                user.setValuesForKeys(dictionary)
                
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })

            }
        
        }, withCancel: nil)
    }
    
    func handleCancel() {
//        revealViewCOntroller.setFrontViewPosition(FrontViewPosition.left, animated: true)//(newFrontViewController, animated: true)
//        dismiss(animated: true, completion: nil)
        
        let messagesVC: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "MessagesController")
        
        self.present(messagesVC!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
//        cell.detailTextLabel?.text = user.email
        
        var url = URL(string: "")
        if(user.photo != ""){
            url = URL(string: user.photo)
        }else{
            url = URL(string: self.noPhoto)
        }

//        if let profileImageUrl = user.photo {
            cell.profileImageView.loadImgUsingCache(url: url!)
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
}










