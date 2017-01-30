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
    var blockeds = [User]()
    var messagesDictionary = [String: User]()
    var long:Double = 0.0
    var lat:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        observeBlockedUsers()
        
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
                
                
                var blockedUser = User(snapShot: snapshot)
                blockedUser.id = userId
                
                self.messagesDictionary[userId] = blockedUser
                
                
                self.attemptReloadOfTable()
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.blockeds = Array(self.messagesDictionary.values)
        self.blockeds.sort(by: { (message1, message2) -> Bool in
            return (message1.name) > (message2.name)
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func showChatControllerForUser(_ user: User) {
        
        let revealViewCOntroller:SWRevealViewController = self.revealViewController()
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let newFrontViewController = UINavigationController.init(rootViewController:desController)
        desController.viewdUserUid = user.id
        desController.lat = self.lat
        desController.long = self.long
        
        revealViewCOntroller.pushFrontViewController(newFrontViewController, animated: true)
        
    }
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blockeds.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let blocked = blockeds[indexPath.row]
        cell.textLabel?.text = blocked.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blocked = blockeds[indexPath.row]
        
        self.showChatControllerForUser(blocked)

    }
    
    
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
