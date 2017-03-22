//
//  CapsuleAnnotation.swift
//  MemoryCap
//
//  Created by Bao Trinh on 3/4/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import Foundation
import MapKit
import FirebaseStorageUI
import FirebaseDatabase

class CapsuleAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var key: String?
    var imageKeyArray: [String]

    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        self.title = "Capsule"
        self.imageKeyArray = []
        super.init()
        
        getCapsuleData()
    }
    
    func getCapsuleData() {
        let ref = FIRDatabase.database().reference().child("capsules")
        ref.child("\(self.key!)").child("images").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    self.imageKeyArray.insert(child.value as! String, at: Int(child.key)!)
                }
            }
        }) { (error) in
        }
    }
}
	
