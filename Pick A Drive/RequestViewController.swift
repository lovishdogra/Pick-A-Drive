//
//  RequestViewController.swift
//  Ryde
//
//  Created by Lovish Dogra on 20/05/16.
//  Copyright © 2016 Lovish Dogra. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!
    
    @IBAction func pickUpRider(_ sender: AnyObject) {
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        
                        let query = PFQuery(className: "riderRequest")
                        query.getObjectInBackground(withId: object.objectId!) { (object, error) in
                            if error != nil {
                                print(error)
                            } else if let object = object {
                                
                                object["driverResponded"] = PFUser.current()!.username!
                                
                                object.saveInBackground()
                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                
                                
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                                    
                                    if error != nil {
                                        
                                        print(error!)
                                        
                                    } else {
                                        
                                        if placemarks!.count > 0 {
                                            
                                            let pm = placemarks![0] 
                                            
                                            let mkPm = MKPlacemark(placemark: pm)
                                            
                                            let mapItem = MKMapItem(placemark: mkPm)
                                            
                                            mapItem.name = self.requestUsername
                                            
                                            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                            
                                            mapItem.openInMaps(launchOptions: launchOptions)
                                            
                                            
                                        } else {
                                            print("Problem with the data received from geocoder")
                                        }
                                        
                                    }
                                })
                            }
                        }
                    }
                }
            } else{
                print(error)
                
            }
        })
        
    }
    
    var requestLocation:CLLocationCoordinate2D!
    var requestUsername:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
