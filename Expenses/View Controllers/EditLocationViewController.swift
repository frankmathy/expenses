//
//  EditLocationViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 05.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit
import MapKit

class EditLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesTableView: UITableView!

    let locationManager = CLLocationManager()
    var expenseLocation : CLLocation?

    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        mapView.delegate = self
        
        let pinImage = UIImage(named: "Pin")
        let imageView = UIImageView(image: pinImage)
        imageView.contentMode = UIViewContentMode.center
        let imageLocation = self.mapView.convert(mapView.centerCoordinate, toPointTo: self.view)
        imageView.center.x = imageLocation.x
        imageView.center.y = imageLocation.y - (pinImage?.size.height)!/2
        imageView.isUserInteractionEnabled = false
        self.view.addSubview(imageView)

        if expenseLocation == nil {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestWhenInUseAuthorization()
                switch(CLLocationManager.authorizationStatus()) {
                case .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                default:
                    showLocationAlert()
                }
                locationManager.startUpdatingLocation()
            } else {
                showLocationAlert()
            }
        } else {
            setEventLocaction(newLocation: expenseLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { expenseLocation = locations.last }
        if expenseLocation == nil {
            // Zoom to user location
            if locations.last != nil {
                self.locationManager.stopUpdatingLocation()
                setEventLocaction(newLocation: locations.last!)
            }
        }
    }
    
    func setEventLocaction(newLocation : CLLocation) {
        self.expenseLocation = newLocation
        let viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        mapView.view(for: mapView.userLocation)?.isHidden = true
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        self.expenseLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
