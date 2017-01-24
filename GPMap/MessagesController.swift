//
//  ViewController.swift
//  gameofchats
//
//  Created by Bruno.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MessagesController: UITableViewController {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    let cellId = "cellId"
    let noPhoto:String = "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac"
    var hasBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //        let image = UIImage(named: "new_message_icon")
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //        observeMessages()
        //        observeUserMessages()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Verifico se existe bloqueio
        let blockRef = FIRDatabase.database().reference().child("user-block").child((FIRAuth.auth()?.currentUser?.uid)!).child(self.messages[indexPath.row].chatPartnerId()!)
        blockRef.observe(.childAdded, with: { (snapshot) in
            self.hasBlocked = true
        }, withCancel: nil)
        
        let block =  UITableViewRowAction(style: .normal, title: "Bloquear")
        { action, index in
            print("bloquear")
            
            let toId = self.messages[indexPath.row].chatPartnerId()
            let fromId = FIRAuth.auth()!.currentUser!.uid
            let childRef = ref.childByAutoId()
            print("toId \(toId) fromId \(fromId)")
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-block").child(fromId).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])

            self.attemptReloadOfTable()
        }
        block.backgroundColor = UIColor.gray
        
        let unBlock =  UITableViewRowAction(style: .normal, title: "Desbloquear")
        { action, index in
            print("desbloquear")
            self.attemptReloadOfTable()
            self.hasBlocked = false
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("user-block").child(uid!).child(self.messages[indexPath.row].chatPartnerId()!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Falha ao desbloquear usuario \(error)")
                    return
                }
            })
        }
        unBlock.backgroundColor = UIColor.green
        
        let delete =  UITableViewRowAction(style: .default, title: "Deletar")
        { action, index in
            print("delete")
            let uid = FIRAuth.auth()?.currentUser?.uid
            let message = self.messages[indexPath.row]
            
            FIRDatabase.database().reference().child("user-messages").child(uid!).child(message.chatPartnerId()!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Falha ao apagar messagem \(error)")
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: message.chatPartnerId()!)
                self.attemptReloadOfTable()
            })
            
        }
        delete.backgroundColor = UIColor.red
        
        if(hasBlocked == true) {
            return [delete, unBlock]
        } else {
            return [delete, block]
        }
    }
    
    func observeUserMessages() {
        let ref = FIRDatabase.database().reference().child("user-messages").child((FIRAuth.auth()?.currentUser?.uid)!)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child((FIRAuth.auth()?.currentUser?.uid)!).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
                
                messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let message = Message()
                        
                        message.setValuesForKeys(dictionary)
                        //                self.messages.append(message)
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messagesDictionary[chatPartnerId] = message
                        }
                        
                        self.attemptReloadOfTable()
                        
                    }
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    var timer: Timer?
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                //                self.messages.append(message)
                
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }
                
                
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //            guard let dictionary = snapshot.value as? [String: AnyObject] else {
            //                return
            //            }
            
            var user = User(snapShot: snapshot)
            user.id = chatPartnerId
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //    func handleNewMessage() {
    //        let newMessageController = NewMessageController()
    //        newMessageController.messagesController = self
    //        let navController = UINavigationController(rootViewController: newMessageController)
    //        present(navController, animated: true, completion: nil)
    
    //        let revealViewCOntroller:SWRevealViewController = self.revealViewController()
    //        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //        let desController = mainStoryboard.instantiateViewController(withIdentifier: "NewMessageController") as! NewMessageController
    //        let newFrontViewController = UINavigationController.init(rootViewController:desController)
    //
    //        revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
    //    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //            if let dictionary = snapshot.value as? [String: AnyObject] {
            //                self.navigationItem.title = dictionary["name"] as? String
            
            let user = User(snapShot:snapshot)
            //                user.setValuesForKeysWithDictionary(dictionary)
            self.setupNavBarWithUser(user)
            //            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.redColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        //        if let profileImageUrl = user.profileImageUrl {
        var url = URL(string: "")
        if(user.photo != ""){
            url = URL(string: user.photo)
        }else{
            url = URL(string: self.noPhoto)
        }
        profileImageView.loadImgUsingCache(url: url!)
        //        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController()))
    }
    
    func showChatControllerForUser(_ user: User) {
        //        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        //        chatLogController.user = user
        //        navigationController?.pushViewController(chatLogController, animated: true)
        
        let revealViewCOntroller:SWRevealViewController = self.revealViewController()
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "ChatLogController") as! ChatLogController
        let newFrontViewController = UINavigationController.init(rootViewController:desController)
        desController.user = user
        
        revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        
    }
    
    func handleLogout() {
        
        //        do {
        //            try FIRAuth.auth()?.signOut()
        //        } catch let logoutError {
        //            print(logoutError)
        //        }
        //
        //        let loginController = LoginController()
        //        loginController.messagesController = self
        //        present(loginController, animated: true, completion: nil)
    }
    
}

