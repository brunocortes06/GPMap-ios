//
//  ChatLogController.swift
//  GPMap
//
//  Created by Bruno Cortes on 10/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    let cellId = "cellId"
    var messages = [Message]()
    var hasBlocked = false
    var wasBlocked = false
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    let inputTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "Digite a mensagem..."
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reportar", style: .plain, target: self, action: #selector(handleReport))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleReport))
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMesageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
    }
    
    func handleReport() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let reportRef = FIRDatabase.database().reference().child("user-reported").child(uid!).child((user?.id)!).child("timestamp")
        let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
        reportRef.setValue(timestamp)
        let alertcontroller = UIAlertController(title: "Aviso", message: "Usuário reportado, você pode bloquear o usuário caso seja necessário", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertcontroller.addAction(defaultAction)
        self.present(alertcontroller, animated: true, completion: nil)
    }
    
    func observeMessages() {
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child((FIRAuth.auth()?.currentUser?.uid)!).child((user?.id)!)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dictionary = snapshot.value as? [String: AnyObject]
                let message = Message()
                message.setValuesForKeys(dictionary!)
                
                self.messages.append(message)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMesageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMesageCell, message: Message){
        let noPhoto:String = "https://firebasestorage.googleapis.com/v0/b/project-3448140967181391691.appspot.com/o/photos%2Fno-user-image.gif?alt=media&token=85dadcce-02e4-4af2-9bc6-e3680c601eac"
        
        var url = URL(string: "")
        if(self.user?.photo != ""){
            url = URL(string: (self.user?.photo)!)
        }else{
            url = URL(string: noPhoto)
        }
        cell.profileImageView.loadImgUsingCache(url: url!)
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMesageCell.blueColor
            cell.profileImageView.isHidden = true
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func estimatedFrameForText(text: String) ->CGRect {
        let size = CGSize(width: 200, height: 1000)
        
        return NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Enviar", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func handleSend(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        //        childRef.updateChildValues(values)
        
        let blockRef = FIRDatabase.database().reference().child("user-block").child((FIRAuth.auth()?.currentUser?.uid)!).child((user?.id)!)
        blockRef.observe(.childAdded, with: { (snapshot) in
            // Se achou o bloqueio retorna e nao cria a mensagem
            let alertcontroller = UIAlertController(title: "Aviso", message: "Você bloqueou este usuário e/ou foi bloqueado", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultAction)
            self.present(alertcontroller, animated: true, completion: nil)
            
            if(!snapshot.key.isEmpty) {
                self.hasBlocked = true
            }
        }, withCancel: nil)

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error?.localizedDescription as Any)
                return
            }
            //Aqui verifico se ele mesmo bloqueou
            if self.hasBlocked == true {
                return
            }
            
            self.inputTextField.text = nil
            
            //Verificar se ao inves de bloquear foi bloqueado, nesse caso, soh nao envio a mensagem
            let blockRef = FIRDatabase.database().reference().child("user-block").child(toId).child(fromId)
            blockRef.observe(.childAdded, with: { (snapshot) in
                
                if(!snapshot.key.isEmpty) {
                   self.wasBlocked = true
                }
            }, withCancel: nil)
            
            if (self.hasBlocked != true && self.wasBlocked != true) {
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            }
        }
    }
    
//    func checkUserBlocked() {
//        let blockRef = FIRDatabase.database().reference().child("user-block").child((FIRAuth.auth()?.currentUser?.uid)!).child((user?.id)!)
//        blockRef.observe(.childAdded, with: { (snapshot) in
//            
//        }, withCancel: nil)
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
