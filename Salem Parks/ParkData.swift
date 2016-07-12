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
        let fileName = NSBundle.mainBundle().pathForResource("park_data", ofType: "json")
        var data: NSData?
        var jsonObject: AnyObject?
        
        do {
            data = try NSData(contentsOfFile: fileName!, options: NSDataReadingOptions(rawValue: 0))
        } catch {
            print("Error getting NSData")
        }
        
        var errorType: ErrorType?
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
        } catch {
            print("Error getting JSON Object")
            errorType = error
        }
        
        if let jsonObject = jsonObject as? [String: AnyObject] where errorType == nil,
            let featuresArray = JSONValue.fromObject(jsonObject)?["features"]?.array {
            
            return featuresArray
        }
        return nil
    }()
    
    
    private func setParkAnnotations() {
        if let jsonDataArray = jsonDataArray {
            for feature in jsonDataArray {
                if let feature = feature.object {
                    if let parkJSON = feature["attributes"] {
                        var title: String?
                        var locationName: String?
                        var discipline: String?
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            parkAddress = parkJSON["ADDRESS"]?.string,
                            parkStatus = parkJSON["STATUS"]?.string,
                            parkID = parkJSON["OBJECTID"]?.integer {
                            
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