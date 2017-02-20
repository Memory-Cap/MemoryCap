//
//  ViewController.swift
//  MemoryCap
//
//  Created by Bao Trinh on 2/15/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import GeoFire

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var capsuleButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    
    // Firebase services
    var database: FIRDatabase!
    var auth: FIRAuth!
    var storage: FIRStorage!
    var geofire: GeoFire!
    
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location
        mapView.showsUserLocation = true
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Photo Picker
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        // Firebase
        database = FIRDatabase.database()
        auth = FIRAuth.auth()
        storage = FIRStorage.storage()
        
        // Using anonymous authentication.
        if FIRAuth.auth()?.currentUser == nil {
            print("YUPPPPPP\n")
            FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
                if let error = error {
                    // TODO: add error alert
                    self.capsuleButton.isEnabled = false
                } else {
                    self.capsuleButton.isEnabled = true
                }
            })
        }
        
        // GeoFire
        geofire = GeoFire(firebaseRef: self.database.reference().child("geo"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    // MARK: - Location Management

    func determineMyCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        
        // print("user latitude = \(userLocation.coordinate.latitude)")
        // print("user longitude = \(userLocation.coordinate.longitude)")
        
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        let latDelta:CLLocationDegrees = 0.02
        let lonDelta:CLLocationDegrees = 0.02
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Photo Management
    
    @IBAction func createCapsule(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        // To have photo picker show as a popover on tablets:
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    // On successful image picking
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        // make sure user is authenticated
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadPhoto(chosenImage)
        
    }
    
    func uploadPhoto(_ image: UIImage) {
        let uuid = UUID().uuidString
        let ref = FIRStorage.storage().reference().child("images").child(uuid + ".jpg")
        let meta = FIRStorageMetadata()
        meta.contentType = "image/jpg"
        
        // 0.8 here is the compression quality percentage
        ref.put(UIImageJPEGRepresentation(image, 0.8)!, metadata: meta, completion: { (imageMeta, error) in
            if error != nil {
                // TODO: handle the error
                return
            }
            
            // most likely required data
            // let downloadURL = imageMeta?.downloadURL()?.absoluteString      // needed to later download the image
            // let imagePath = imageMeta?.path     // needed if you want to be able to delete the image later
            // optional data
            // let timeStamp = imageMeta?.timeCreated
            // let size = imageMeta?.size
            
            // Save image name to database under root->"capsules"->autoId->index
            let capsuleRef = self.database.reference().child("capsules").childByAutoId()
            capsuleRef.child("0").setValue(uuid) // '0' for first image in capsule; we'll add multiple images later
            
            // Store geolocation data for the capsule
            let location = self.mapView.userLocation.location
            self.geofire!.setLocation(self.mapView.userLocation.location, forKey: capsuleRef.key)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

