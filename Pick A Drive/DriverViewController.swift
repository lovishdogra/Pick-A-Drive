//
//  DriverViewController.swift
//  Ryde
//
//  Created by Lovish Dogra on 19/05/16.
//  Copyright © 2016 Lovish Dogra. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverViewController: UITableViewController,CLLocationManagerDelegate {
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager:CLLocationManager!
    
    var latitude:CLLocationDegrees = 0.0
    var longitude:CLLocationDegrees = 0.0

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
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        query.limit = 10
        query.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                print("successfully retrieved")
                
                if let objects = objects {
                    
                    
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        if object["driveResponded"] == nil {
                        if let username = object["username"] as? String {
                            self.usernames.append(username)
                        }
                        
                        if let returnedLocation = object["location"] as? PFGeoPoint {
                            let requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            
                            self.locations.append(requestLocation)
                            
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                            let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                            let distance = driverCLLocation.distance(from: requestCLLocation)
                            
                            self.distances.append(distance/1000)

                        }
                        }
                    }
                    self.tableView.reloadData()
                    
                }
                
            } else{
                print(error)
                
            }
        })
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let distanceDouble = Double(distances[indexPath.row])
        let roundedDistance = Double(round(distanceDouble * 10) / 10)
        cell.textLabel?.text = usernames[indexPath.row] + " is " + String(roundedDistance) + " Km away"

        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutDriver" {
            PFUser.logOut()
            print("successfully logout driver")
        } else if segue.identifier == "showViewRequests" {
            if let destination = segue.destination as? RequestViewController {
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
            
        }
    }

}
