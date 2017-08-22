//
//  ParkData.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/26/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import MapKit

class ParkData {
    
    var parkAnnotations = [ParkAnnotation]()
    
    func getMapAnnotations() -> [ParkAnnotation] {
        setParkAnnotations()

        return parkAnnotations
    }
    
    var jsonDataArray: [JSONValue]? = {
        let fileName = Bundle.main.path(forResource: "park_data", ofType: "json")
        var data: Data?
        //var jsonObject: AnyObject?
        var jsonObject: Any?
        
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: fileName!), options: NSData.ReadingOptions(rawValue: 0))
        } catch {
            print("Error getting NSData")
        }
        
        var errorType: Error?
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
        } catch {
            print("Error getting JSON Object")
            errorType = error
        }
        
//        if let jsonObject = jsonObject as? [String: AnyObject], errorType == nil,
//            let featuresArray = JSONValue.fromObject(jsonObject)?["features"]?.array {
//            
//            return featuresArray
//        }
        if let jsonObjct = jsonObject as AnyObject?, errorType == nil,
            let featuresArray = JSONValue.fromObject(jsonObjct)?["features"]?.array {
            
            return featuresArray
        }
        return nil
    }()
    
    
    fileprivate func setParkAnnotations() {
        if let jsonDataArray = jsonDataArray {
            for feature in jsonDataArray {
                if let feature = feature.object {
                    if let parkJSON = feature["attributes"] {
                        var title: String?
                        var locationName: String?
                        var discipline: String?
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            let parkAddress = parkJSON["ADDRESS"]?.string,
                            let parkStatus = parkJSON["STATUS"]?.string,
                            let parkID = parkJSON["OBJECTID"]?.integer {
                            
                            title = parkName
                            locationName = parkAddress
                            discipline = parkStatus
                            
                            if let coordinate = ParkAnnotation.getCoordinate(forParkID: parkID) {
                                let park = ParkAnnotation(title: title!, locationName: locationName!, discipline: discipline!, coordinate: coordinate, objectID: parkID)
                                parkAnnotations.append(park)
                            }
                        }
                    }
                }
            }
        }
    }
}
