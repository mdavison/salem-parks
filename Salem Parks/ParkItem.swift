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
    var street: String?
    var objectID: Int?
    var hasRestrooms = false
    var hasPlayEquipment = false
    var hasPicnicTables = false
    var hasPicnicShelter = false
    
    static func getAll() -> [ParkItem] {
        var parkItems = [ParkItem]()
        let parkData = ParkData()
        
        if let jsonDataArray = parkData.jsonDataArray {
            for item in jsonDataArray {
                
                if let feature = item.object {
                    if let parkJSON = feature["attributes"] {
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            parkAddress = parkJSON["ADDRESS"]?.string,
                            objectID = parkJSON["OBJECTID"]?.integer,
                            restrooms = parkJSON["RESTROOMS"]?.string,
                            playEquip = parkJSON["PLAY_EQUIPMENT"]?.string,
                            picnicTables = parkJSON["PICNIC_TABLES"]?.string,
                            picnicShelter = parkJSON["PICNIC_SHELTER"]?.string {
                            
                            var parkItem = ParkItem()
                            parkItem.parkName = parkName
                            parkItem.street = parkAddress
                            parkItem.objectID = objectID
                            //print("has picnic tables: \(picnicTables)")
                            
                            parkItem.hasRestrooms = restrooms == "Yes" ? true : false
                            parkItem.hasPlayEquipment = playEquip == "Yes" ? true : false
                            parkItem.hasPicnicTables = picnicTables == "Yes" ? true : false
                            parkItem.hasPicnicShelter = picnicShelter == "Yes" ? true : false
                            
                            parkItems.append(parkItem)
                        }
                    }
                }
                
            }
        }
        
        return parkItems
    }
}