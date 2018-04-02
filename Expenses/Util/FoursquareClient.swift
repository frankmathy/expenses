//
//  FoursquareClient.swift
//  Expenses
//
//  Created by Frank Mathy on 02.04.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import MapKit

struct FoursquareVenue {
    var id : String
    var name : String
    var category : String
    var address : String?
    var lat : Double
    var lng : Double
}

class FoursquareClient {
    
    func search(atLocation currentLocation : CLLocationCoordinate2D, completionHandler: @escaping ([FoursquareVenue]?, Error?) -> Swift.Void) {
        let today = Date()
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=\(today.asYYYYMMDDString)&intent=browse&limit=15&radius=500&client_id=\(AppCredentials.foursquareClientId)&client_secret=\(AppCredentials.foursquareClientSecret)"
        print(url)
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, err) in
            if err != nil {
                print("Error retrieving data from Foursquare: \(err.debugDescription)")
                completionHandler(nil, err)
                return
            }
            do {
                
                let json = try JSON(data: data!)
                let searchResults = json["response"]["group"]["results"].arrayValue
                let sortedResults = searchResults.sorted(by: { (json1, json2) -> Bool in
                    return json1["venue"]["location"]["distance"].int! < json2["venue"]["location"]["distance"].int!
                })
                var venues = [FoursquareVenue]()
                for result in sortedResults {
                    let venue = FoursquareVenue(id: result["venue"]["id"].string!, name: result["venue"]["name"].string!, category: result["venue"]["categories"][0]["name"].string!, address: result["venue"]["location"]["address"].string, lat: result["venue"]["location"]["lat"].double!, lng: result["venue"]["location"]["lng"].double!)
                    venues.append(venue)
                }
                completionHandler(venues, nil)
            } catch {
                completionHandler(nil, NSError(domain: "Error loading data", code: 0, userInfo: nil))
            }
        }
        
        task.resume()
    }

}
