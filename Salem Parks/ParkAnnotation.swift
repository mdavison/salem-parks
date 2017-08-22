//
//  ParkAnnotation.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/26/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import MapKit
import Contacts

class ParkAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let objectID: Int
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, objectID: Int) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.objectID = objectID
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    static func getCoordinate(forParkID parkID: Int) -> CLLocationCoordinate2D? {
        if let path = Bundle.main.path(forResource: "ParkCoordinates", ofType: "plist") {
            if let parks = NSDictionary(contentsOfFile: path) {
                if let lat = (parks.object(forKey: "\(parkID)") as AnyObject).object(forKey: "latitude") as? Double,
                    let long = (parks.object(forKey: "\(parkID)") as AnyObject).object(forKey: "longitude") as? Double {

                    return CLLocationCoordinate2D(latitude: lat, longitude: long)
                }
            }
        }

        return nil
    }
    
    // Annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        //let postalAddress = CNPostalAddress
        let addressDictionary = [String(CNPostalAddressStreetKey): subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        return mapItem
    }
    
}
