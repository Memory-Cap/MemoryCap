//
//  BackpackVC.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/17/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import Firebase
import Pager

class BackpackVC: PagerController, PagerDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        // Instantiating Storyboard ViewControllers
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller1 = storyboard.instantiateViewController(withIdentifier: "unlockedCapsules")
        let controller2 = storyboard.instantiateViewController(withIdentifier: "lockedCapsules")
        let controller3 = storyboard.instantiateViewController(withIdentifier: "Settings")

        
        // Setting up the PagerController with Name of the Tabs and their respective ViewControllers
        self.setupPager(
            tabNames: ["Unlocked", "Locked", "Settings"],
            tabControllers: [controller1, controller2, controller3])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
}

