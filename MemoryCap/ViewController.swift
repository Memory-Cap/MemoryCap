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

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
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
        mapView.delegate = self
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
        locationAuthStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoIdentifier = "Capsule"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "user")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? CapsuleAnnotation {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "capsule")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showCapsules(location: loc)
    }
    
    // MARK: - Capsule Management
    
    @IBAction func createCapsule(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        // To have photo picker show as a popover on tablets:
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    func showCapsules(location : CLLocation) {
        let circleQuery = geofire!.query(at: location, withRadius: 2)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = CapsuleAnnotation(coordinate: location.coordinate, key: key)
                self.mapView.addAnnotation(anno)
            }
        })
    }
    
    // MARK: - Photo Management
    
    // On successful image picking
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        // make sure user is authenticated
        guard let _ = FIRAuth.auth()?.currentUser?.uid else { return }
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
            capsuleRef.child("images").child("0").setValue(uuid) // '0' for first image in capsule; we'll add multiple images later
            
            // Store geolocation data for the capsule
            self.geofire!.setLocation(self.mapView.userLocation.location, forKey: capsuleRef.key)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

