//
//  BlockedUsersController.swift
//  GPMap
//
//  Created by Bruno Cortes on 19/01/17.
//  Copyright © 2017 Change Logic. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class BlockedUsersController: UITableViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func observeBlockedUsers() {
        let ref = FIRDatabase.database().reference().child("user-block").child((FIRAuth.auth()?.currentUser?.uid)!)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            let ref = FIRDatabase.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                //                return
                //            }
                
                let user = User(snapShot: snapshot)
                self.showChatControllerForUser(user: user)
                
            }, withCancel: nil)
            
//            FIRDatabase.database().reference().child("user-messages").child((FIRAuth.auth()?.currentUser?.uid)!).child(userId).observe(.childAdded, with: { (snapshot) in
//                
//                let messageId = snapshot.key
//                let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
//                
//                messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let dictionary = snapshot.value as? [String: AnyObject] {
//                        let message = Message()
//                        
//                        message.setValuesForKeys(dictionary)
//                        //                self.messages.append(message)
//                        
//                        if let chatPartnerId = message.chatPartnerId() {
//                            self.messagesDictionary[chatPartnerId] = message
//                        }
//                        
//                        self.attemptReloadOfTable()
//                        
//                    }
//                }, withCancel: nil)
//            }, withCancel: nil)
        }, withCancel: nil)
    }

    func showChatControllerForUser(user:User){
        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
