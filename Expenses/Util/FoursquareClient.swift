//
//  FoursquareClient.swift
//  Expenses
//
//  Created by Frank Mathy on 02.04.18.
//  Copyright © 2018 Frank Mathy. All rights reserved.
//

import Foundation
import MapKit

class FoursquareClient {
    
    func search(atLocation currentLocation : CLLocationCoordinate2D) {
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=browse&limit=15&radius=500&client_id=\(client_id)&client_secret=\(client_secret)"
        print(url)
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, err) in
            do {
                let json = try JSON(data: data!)
                let searchResults = json["response"]["group"]["results"].arrayValue
                print("Found \(searchResults.count) Foursquare places")
                for result in searchResults {
                    let id = result["venue"]["id"].string!
                    let name = result["venue"]["name"].string!
                    let category = result["venue"]["categories"][0]["name"].string!
                    let address = result["venue"]["location"]["address"].string
                    let lat = result["venue"]["location"]["lat"].double
                    let lng = result["venue"]["location"]["lng"].double
                    let distance = result["venue"]["location"]["distance"].int
                    print("Venue: Id=\(id), Name=\(name), Category=\(category), Address=\(address), distance=\(distance), coord=(\(lat),\(lng))")
                }
                DispatchQueue.main.async {
                    // TODO
                }
            } catch {
                
            }
        }
        
        task.resume()
    }

}
