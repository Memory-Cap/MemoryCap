//
//  CapsuleViewController.swift
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
import BSImagePicker
import Photos

class CapsuleViewController: UIViewController, UITextFieldDelegate {
    var database: FIRDatabase!
    var auth: FIRAuth!
    var storage: FIRStorage!
    var geofire: GeoFire!
    
    var mapView: MKMapView!
    
    var selectedImages = [PHAsset]()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleField.delegate = self
//        database = FIRDatabase.database()
//        auth = FIRAuth.auth()
//        storage = FIRStorage.storage()
//        geofire = GeoFire(firebaseRef: self.database.reference().child("geo"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    // MARK: - Capsule Management
    
    @IBAction func chooseImages(_ sender: Any) {
        //        present(imagePicker, animated: true, completion: nil)
        //        // To have photo picker show as a popover on tablets:
        //        imagePicker.modalPresentationStyle = .popover
        //        imagePicker.popoverPresentationController?.barButtonItem = sender
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 6
        
        bs_presentImagePickerController(vc, animated: true,
        select: { (asset: PHAsset) -> Void in
//            print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
//            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
//            print("Cancel: \(assets)")
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish: \(assets)")
            print(assets.count)
            for i in 0..<assets.count
            {
                self.selectedImages.append(assets[i])
                print(self.selectedImages)
            }
        }, completion: nil)
    }
    
    // MARK: - Photo Management
    
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
    
    
    @IBAction func submit(_ sender: Any) {
        let capsuleRef = self.database.reference().child("capsules").childByAutoId()
        
        // Get title
        let title = titleField.text!
        capsuleRef.child(String("title")).setValue(title)
        
        // Get images
        if selectedImages.count != 0{
            for i in 0..<selectedImages.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedImages[i], targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                // got UIImage from PHAsset, upload it
                uploadPhoto(capsuleRef, i: i, image: thumbnail)
            }
        }
        
        // Store geolocation data for the capsule
        self.geofire!.setLocation(self.mapView.userLocation.location, forKey: capsuleRef.key)
        print("done")
    }
}
