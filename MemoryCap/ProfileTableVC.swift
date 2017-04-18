//
//  ProfileTableViewController.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/12/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import Firebase

class ProfileTableViewController: UITableViewController {
    // locked and unlocked
    var capsules: [[String]] = [[],[]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return capsules[collectionView.tag].count + 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capsules.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ProfileTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ProfileTableViewCell else { return }
        
//        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    
    func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
}

extension ProfileTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capsules[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
//        cell.backgroundColor = capsules[collectionView.tag][indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
