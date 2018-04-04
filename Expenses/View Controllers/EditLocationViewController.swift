//
//  EditLocationViewController.swift
//  Expenses
//
//  Created by Frank Mathy on 05.03.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import UIKit
import MapKit

class VenueAnnotation : MKPointAnnotation {
    var venue : FoursquareVenue?
}

class EditLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var venueId : String?
    var venueName : String?
    var venueLat : Double?
    var venueLng : Double?
    
    var visibleLocation : CLLocation?

    let regionRadius: CLLocationDistance = 200
    let maxVenuesOnMap = 50
    
    let selectedVenueString = NSLocalizedString("Selected Venue", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        mapView.delegate = self
        
        if venueId == nil {
            addressLabel.text = selectedVenueString + "-"
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
            addressLabel.text = selectedVenueString + venueName!
            setVisibleLocaction(newLocation: CLLocation(latitude: venueLat!, longitude: venueLng!))
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let venueAnnotation = view.annotation as? VenueAnnotation {
            venueId = venueAnnotation.venue?.id
            venueName = venueAnnotation.venue?.name
            venueLat = venueAnnotation.venue?.lat
            venueLng = venueAnnotation.venue?.lng
            addressLabel.text = selectedVenueString + venueName!
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        venueId = nil
        venueName = nil
        venueLat = Double.nan
        venueLng = Double.nan
        addressLabel.text = selectedVenueString + "-"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { visibleLocation = locations.last }
        if visibleLocation == nil {
            // Zoom to user location
            if locations.last != nil {
                self.locationManager.stopUpdatingLocation()
                setVisibleLocaction(newLocation: locations.last!)
            }
        }
    }
    
    func setVisibleLocaction(newLocation : CLLocation) {
        self.visibleLocation = newLocation
        let viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(viewRegion, animated: false)
        refreshLocationDescription()
    }
    
    func refreshLocationDescription() {
        if visibleLocation != nil {
            // Determine visible radius
            let region = mapView.region
            let leftTop = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta/2, longitude: region.center.longitude - region.span.longitudeDelta/2)
            let center = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let radius = center.distance(from: leftTop)
            
            mapView.removeAnnotations(mapView.annotations)
            let foursquare = FoursquareClient()
            foursquare.search(atLocation: (visibleLocation?.coordinate)!, radius: Int(radius), resultLimit: maxVenuesOnMap) { (venues, error) in
                if venues != nil {
                    DispatchQueue.main.async {
                        var selectedVenueAnnotation : VenueAnnotation?
                        for venue in venues! {
                            let coord = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lng)
                            let annotation = VenueAnnotation()
                            annotation.coordinate = coord
                            annotation.title = venue.name
                            annotation.subtitle = venue.address
                            annotation.venue = venue
                            self.mapView.addAnnotation(annotation)
                            if self.venueId == venue.id {
                                selectedVenueAnnotation = annotation
                            }
                        }
                        
                        if selectedVenueAnnotation == nil && self.venueId != nil {
                            let annotation = VenueAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: self.venueLat!, longitude: self.venueLng!)
                            annotation.title = self.venueName
                            annotation.venue = FoursquareVenue(id: self.venueId!, name: self.venueName!, category: "", address: "", lat: self.venueLat!, lng: self.venueLng!)
                        }
                        
                        if selectedVenueAnnotation != nil {
                            self.mapView.selectAnnotation(selectedVenueAnnotation!, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Location Disabled", comment: ""), message: NSLocalizedString("Please enable location", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        self.visibleLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        refreshLocationDescription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
/*    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "VenuePin") as! MKPinAnnotationView?
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "VenuePin")
        } else {
            pin?.annotation = annotation
        }
        pin?.pinTintColor = MKPinAnnotationView.greenPinColor()
        return pin
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
