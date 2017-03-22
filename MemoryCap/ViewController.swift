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
import BSImagePicker
import Photos

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
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
        
        
        // Firebase
        database = FIRDatabase.database()
        auth = FIRAuth.auth()
        storage = FIRStorage.storage()
        
        // Using anonymous authentication.
        if FIRAuth.auth()?.currentUser == nil {
            FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error: Error?) in
                
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
    
    func showCapsules(location : CLLocation) {
        let circleQuery = geofire!.query(at: location, withRadius: 2)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = CapsuleAnnotation(coordinate: location.coordinate, key: key)
                self.mapView.addAnnotation(anno)
            }
        })
    }
    
    //MARK:- ViewController Transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCapsule" {
            let childViewController = segue.destination as! CapsuleViewController
            childViewController.database = self.database
            childViewController.auth = self.auth
            childViewController.storage = self.storage
            childViewController.geofire = self.geofire
            childViewController.mapView = self.mapView
        }
    }
}

