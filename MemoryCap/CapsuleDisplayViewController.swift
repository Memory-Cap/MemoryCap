//
//  CapsuleDisplayViewController.swift
//  MemoryCap
//
//  Created by Bao Trinh on 3/22/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import GeoFire
import ImageSlideshow
import Photos

class CapsuleDisplayViewController: UIViewController {
    var database: FIRDatabase!
    var auth: FIRAuth!
    var storage: FIRStorage!
    var geofire: GeoFire!
    
    var mapView: MKMapView!
    
    var key: String!

    var imageKeyArray: [String] = []
    var imageSource: [ImageSource] = []
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getCapsuleData()
        
        slideshow.backgroundColor = UIColor.white
        slideshow.slideshowInterval = 5.0
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideshow.pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

    }
    
    func getCapsuleData() {
        // Get images
        let ref = FIRDatabase.database().reference().child("capsules")
        ref.child("\(self.key!)").child("images").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    self.imageKeyArray.insert(child.value as! String, at: Int(child.key)!)
                    print("+++ inserted key: [\(child.key)] \(child.value)")
                    let uuid = child.value as! String
                    let imageRef = FIRStorage.storage().reference().child("images").child("\(uuid).jpg")
                    imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print(error)
                        } else {
                            self.imageSource.append(ImageSource(image: UIImage(data: data!)!))
                            print("+++ Downloaded image: \(uuid)")
                            self.slideshow.setImageInputs(self.imageSource)
                        }
                    }
                }
                
            }
        }) { (error) in
        }
        // Get title
        ref.child("\(self.key!)").child("title").observe(.value, with: { snapshot in
            self.title = (snapshot.value as! String)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
