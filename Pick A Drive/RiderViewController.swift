//
//  RiderViewController.swift
//  Pick A Drive
//
//  Created by Lovish Dogra on 19/05/16.
//  Copyright © 2016 Lovish Dogra. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var bookBtn: UIButton!
    
    var locationManager:CLLocationManager!
    var riderRequestActive = false
    var latitude:CLLocationDegrees = 0.0
    var longitude:CLLocationDegrees = 0.0
    
    func displayAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func bookRyde(_ sender: AnyObject) {
        if riderRequestActive == false {
            let riderRequest = PFObject(className: "riderRequest")
            riderRequest["username"] = PFUser.current()?.username
            riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
            
            riderRequest.saveInBackground { (success, error) in
                if(success){
                    print("riderRequest saved")
                    
                    self.bookBtn.setTitle("Cancel booking", for: UIControlState())
                    
                    
                    
                } else {
                    self.displayAlert("Unable to book", message: "Try Again")
                    
                }
            }
            riderRequestActive = true
        } else{
            self.bookBtn.setTitle("Book a Ryde", for: UIControlState())
            
            riderRequestActive = false
            
            let query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    print("successfully retrieved")
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                            
                        }
                    }
                } else{
                    print(error)
                    
                }
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = (manager.location?.coordinate)!
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        print("location = \(location.latitude) \(location.longitude)")
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(self.map.annotations)
        
        let pinLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your Location"
        self.map.addAnnotation(objectAnnotation)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutRider" {
            PFUser.logOut()
            print("successfully logout")
        }
    }
    
}
