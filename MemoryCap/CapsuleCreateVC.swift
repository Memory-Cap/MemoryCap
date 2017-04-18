//
//  CapsuleCreateVC.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/16/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import GeoFire
import Photos
import ImageSlideshow
import ImagePicker
import DatePickerCell
import SkyFloatingLabelTextField

class CapsuleCreateVC: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, ImagePickerDelegate {
    var database: FIRDatabase!
    var auth: FIRAuth!
    var storage: FIRStorage!
    var geofire: GeoFire!
    
    var lat: CLLocationDegrees = 0.0
    var lon: CLLocationDegrees = 0.0
    
    let locationManager = CLLocationManager()
    
    var selectedImages = [UIImage]()
    
    let imagePickerController = ImagePickerController()

    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var datePicker: DatePickerCell!
    @IBOutlet weak var titleField: SkyFloatingLabelTextField!
    @IBOutlet weak var descriptionField: SkyFloatingLabelTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func submitPressed(_ sender: Any) {
        submit()
    }
    @IBAction func cancelPressed(_ sender: Any) {
        exitPage()
    }
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // buttons
        self.submitButton.layer.cornerRadius = self.submitButton.frame.height / 4
        self.cancelButton.layer.cornerRadius = self.cancelButton.frame.height / 4
        
        // input fields
        self.titleField.delegate = self
        self.titleField.tag = 0
        self.titleField.selectedTitleColor = colorWithHexString("C03E30")
        self.titleField.selectedLineColor = colorWithHexString("C03E30")
        self.descriptionField.delegate = self
        self.descriptionField.tag = 1
        self.descriptionField.selectedTitleColor = colorWithHexString("C03E30")
        self.descriptionField.selectedLineColor = colorWithHexString("C03E30")
        self.hideKeyboardWhenTappedAround()
        
        // Firebase
        database = FIRDatabase.database()
        auth = FIRAuth.auth()
        storage = FIRStorage.storage()
        
        // GeoFire
        geofire = GeoFire(firebaseRef: self.database.reference().child("geo"))
        
        // image picker
        imagePickerController.delegate = self
        
        // Slideshow
        slideshow.slideshowInterval = 0
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideshow.pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.setImageInputs([
            ImageSource(image: UIImage(named: "finallogo")!)
            ])
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        slideshow.addGestureRecognizer(gestureRecognizer)
        
        determineMyCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewDidAppear Selected images: \(selectedImages.count)")
        if (selectedImages.count == 0) {
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearFields() {
        slideshow.setImageInputs([
            ImageSource(image: UIImage(named: "finallogo")!)
            ])
        titleField.text = ""
        descriptionField.text = ""
        selectedImages = []
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch (textField.tag) {
        case 0:
            descriptionField.becomeFirstResponder()
            break;
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let userLocation:CLLocation = locations[0] as! CLLocation
        self.lon = userLocation.coordinate.longitude;
        self.lat = userLocation.coordinate.latitude;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Get the correct height if the cell is a DatePickerCell.
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        if (cell.isKind(of: DatePickerCell.self)) {
            return (cell as! DatePickerCell).datePickerHeight()
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if (indexPath.row == 2) {
            self.titleField.becomeFirstResponder()
        } else if (indexPath.row == 3) {
            self.descriptionField.becomeFirstResponder()
        }
        
        // Deselect automatically if the cell is a DatePickerCell.
        if (cell.isKind(of: DatePickerCell.self)) {
            let datePickerTableViewCell = cell as! DatePickerCell
            datePickerTableViewCell.selectedInTableView(tableView)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Photo Management
    
    func chooseImages(_ sender: Any) {
        imagePickerController.imageLimit = 10
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // On successful image picking
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        // make sure user is authenticated
        guard let _ = FIRAuth.auth()?.currentUser?.uid else { return }
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadPhoto(self.database.reference().child("capsules").childByAutoId(), i: 0, image: chosenImage)
    }
    
    func uploadPhoto(_ capsuleRef: FIRDatabaseReference, i: Int, image: UIImage) {
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
            capsuleRef.child("images").child(String(i)).setValue(uuid)
        })
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func didTap() {
        slideshow.presentFullScreenController(from: self)
    }
    
    // MARK: - Submit
    
    func submit() {
        let capsuleRef = self.database.reference().child("capsules").childByAutoId()
        
        // Get title
        let title = titleField.text!
        capsuleRef.child(String("title")).setValue(title)
        
        // Store user id
        let userid = FIRAuth.auth()?.currentUser?.uid
        capsuleRef.child(String("owner")).setValue(userid)
        
        // Store date created
        capsuleRef.child(String("created")).setValue(NSDate().timeIntervalSince1970)
        
        // Store unlock date
        let lockdate = datePicker.date
        capsuleRef.child(String("unlockby")).setValue(lockdate.timeIntervalSince1970)
        
        // Store this capsule to user's list of capsules
        let ownercaps = self.database.reference().child("users").child(userid!).child(String("created"))
        ownercaps.child(capsuleRef.key).setValue(lockdate.timeIntervalSince1970)
        
        // Store description
        let description = descriptionField.text!
        capsuleRef.child(String("description")).setValue(description)
        
        // Store coordinates (as plain coordinates)
        capsuleRef.child(String("coordinates")).setValue(["Latitude": lat, "Longitude": lon])
        
        // Get images
        if (selectedImages.count != 0) {
            for i in 0..<selectedImages.count{
                uploadPhoto(capsuleRef, i: i, image: selectedImages[i])
            }
        }
        
        // Store geolocation data for the capsule (as geofire hash)
        self.geofire!.setLocation(CLLocation(latitude: lat, longitude: lon), forKey: capsuleRef.key)
        print("done")
        
        exitPage()
    }
    
    // MARK: - Location
    
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
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        lat = userLocation.coordinate.latitude
        lon = userLocation.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    // MARK: - ImagePickerDelegate
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        exitPage()
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if (images.count > 0) {
            self.selectedImages = []
            self.slideshow.setImageInputs(images.map({
                (temp: UIImage) -> InputSource in
                self.selectedImages.append(temp)
                return ImageSource(image: temp)
            }))
        }
        print("Selected images: \(selectedImages.count)")
    }
    
    func exitPage() {
        clearFields()
        self.tabBarController?.selectedIndex = 0
    }
}
