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
import ImageSlideshow
import Photos
import SkyFloatingLabelTextField
import SCLAlertView

class CapsuleDisplayViewController: UITableViewController, MKMapViewDelegate {
    var key: String!
    var capsuleTitle: String!

    var imageKeyArray: [String] = []
    var imageSource: [ImageSource] = []
    var lat: CLLocationDegrees = 0
    var lon: CLLocationDegrees = 0
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var unlockedField: SkyFloatingLabelTextField!
    @IBOutlet weak var createdField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // minimap
        self.mapView.delegate = self
        self.mapView.isScrollEnabled = false
        
        getCapsuleData()
        
        // slideshow properties
        slideshow.backgroundColor = UIColor.white
        slideshow.slideshowInterval = 0
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideshow.pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // slideshow fullscreen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        slideshow.addGestureRecognizer(gestureRecognizer)
        
        deleteButton.isHidden = true
    }
    
    func getCapsuleData() {
        let ref = database.reference().child("capsules").child("\(self.key!)")
        
        ref.observe(.value, with: { snapshot in
            // Get title
            self.capsuleTitle = snapshot.childSnapshot(forPath: "title").value as! String!
            self.title = self.capsuleTitle
            
            // Get description
            self.descriptionText.text = ""
            self.descriptionText.text = snapshot.childSnapshot(forPath: "description").value as! String!
            print("Description: \(self.descriptionText.text)")
            
            // Get image list
            if let result = snapshot.childSnapshot(forPath: "images").children.allObjects as? [FIRDataSnapshot] {
                self.imageKeyArray = []
                for child in result {
                    if let uuid = child.value as! String! {
                        self.imageKeyArray.append(uuid)
                    }
                }
            }
            
            // Get dates
            let createdDate = snapshot.childSnapshot(forPath: "created").value as! TimeInterval
            self.createdField.text = "\(NSDate.init(timeIntervalSince1970: createdDate))"
            let unlockDate = snapshot.childSnapshot(forPath: "unlockby").value as! TimeInterval
            self.unlockedField.text = "\(NSDate.init(timeIntervalSince1970: unlockDate))"
            
            
            // Get images
            for uuid in self.imageKeyArray {
                let imageRef = storage.reference().child("images").child("\(uuid).jpg")
                imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print(error ?? "Fudged up")
                    } else {
                        self.imageSource.append(ImageSource(image: UIImage(data: data!)!))
                        print("+++ Downloaded image: \(uuid)")
                        self.slideshow.setImageInputs(self.imageSource)
                    }
                }
            }
            
            // Get coordinates
            let coor = snapshot.childSnapshot(forPath: "coordinates")
            let latDelta:CLLocationDegrees = 0.02
            let lonDelta:CLLocationDegrees = 0.02
            let span = MKCoordinateSpanMake(latDelta, lonDelta)
            var location = CLLocationCoordinate2DMake(self.lat, self.lon)
            var region = MKCoordinateRegionMake(location, span)
            self.lat = coor.childSnapshot(forPath: "Latitude").value as! CLLocationDegrees
            self.lon = coor.childSnapshot(forPath: "Longitude").value as! CLLocationDegrees
            location = CLLocationCoordinate2DMake(self.lat, self.lon)
            region = MKCoordinateRegionMake(location, span)
            self.mapView.setRegion(region, animated: false)
        })
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTap() {
        slideshow.presentFullScreenController(from: self)
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            //            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            //            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            //            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Yes, delete") {
            self.deleteCapsule()
        }
        alertView.addButton("Cancel") {
            print("canceled deletion")
        }
        
        alertView.showWarning("Delete", subTitle: "Are you sure?")
    }
    
    func deleteCapsule() {
    }
    
    @IBAction func reportPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            //            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            //            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            //            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Spam") {
            self.report("spam")
        }
        alertView.addButton("Inappropriate") {
            self.report("inappropriate")
        }
        alertView.addButton("Threatening/Harrassment") {
            self.report("harrassment")
        }
        alertView.addButton("Other") {
            self.report("other")
        }
        alertView.addButton("Cancel") {
            print("canceled report")
        }
        
        alertView.showNotice("Report", subTitle: "What's the problem?")
    }
    
    func report(_ reason: String) {
        let capsuleRef = database.reference().child("reports").child(self.key)
        let userid = FIRAuth.auth()?.currentUser?.uid
        capsuleRef.child(userid!).setValue(reason)
    }
}
