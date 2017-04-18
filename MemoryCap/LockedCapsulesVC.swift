//
//  LockedCapsulesVC.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/17/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import Firebase

class LockedCapsulesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var capsules: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("users").child(userid!)
        ref.child("created").observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    let unlockdate = child.value as! TimeInterval
                    let key = child.key
                    if (unlockdate > NSDate().timeIntervalSince1970) {
                        self.capsules.append(key)
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capsules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BackpackCell
        cell.key = capsules[indexPath.row]
        
        let ref = FIRDatabase.database().reference().child("capsules").child("\(cell.key!)")
        
        ref.observe(.value, with: { snapshot in
            // Get title
            cell.caption.text = snapshot.childSnapshot(forPath: "title").value as! String!
            
            // Get image list
            if let result = snapshot.childSnapshot(forPath: "images").children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    if let uuid = child.value as! String! {
                        cell.imageKeyArray.append(uuid)
                    }
                }
                // Get images
                if (cell.imageKeyArray.count > 0) {
                    let imageRef = FIRStorage.storage().reference().child("images").child("\(cell.imageKeyArray[0]).jpg")
                    imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print(error ?? "Fudged up")
                        } else {
                            cell.preview.image = UIImage(data: data!)
                        }
                    }
                } else {
                    print("YOOOO WTFFFFF")
                }
            }
        })
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row: \(indexPath.row)")
        performSegue(withIdentifier: "goToCapsuleDisplay", sender: (tableView.cellForRow(at: indexPath) as! BackpackCell).key)
        return
    }
    
    
    //MARK:- ViewController Transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCapsuleDisplay" {
            let childViewController = segue.destination as! CapsuleDisplayViewController
            childViewController.key = sender as! String!
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
}
