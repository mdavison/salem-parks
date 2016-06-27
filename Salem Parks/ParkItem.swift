//
//  ParkItem.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/26/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation

struct ParkItem {
    var parkName: String?
    
    static func getAll() -> [ParkItem] {
        var parkItems = [ParkItem]()
        let parkData = ParkData()
        
        if let jsonDataArray = parkData.jsonDataArray {
            for item in jsonDataArray {
                
                if let feature = item.object {
                    if let parkJSON = feature["attributes"] {
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            parkAddress = parkJSON["ADDRESS"]?.string,
                            parkStatus = parkJSON["STATUS"]?.string,
                            parkID = parkJSON["OBJECTID"]?.integer {
                            
                            
                            
                            let parkItem = ParkItem(parkName: parkName)
                            parkItems.append(parkItem)
                        }
                    }
                }
                
            }
        }
        
        return parkItems
    }
}