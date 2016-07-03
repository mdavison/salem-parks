//
//  ParkItem.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/26/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

//import Foundation

//struct ParkItem {
//    var parkName: String?
//    var street: String?
//    var objectID: Int?
//    var status: String?
//    var daysOpen: String?
//    var hours: String?
//    var parkType: String?
//    var hasRestrooms: Bool?
//    var hasPlayEquip: Bool?
//    var hasPicnicTables: Bool?
//    var hasPicnicShelter: Bool?
//    var hasBallfields: Bool?
//    var hasSoccer: Bool?
//    var hasJogging: Bool?
//    var hasWalking: Bool?
//    var hasBike: Bool?
//    var hasMultiUseCourt: Bool?
//    var hasTennis: Bool?
//    var hasHorseshoes: Bool?
//    var hasSprayPad: Bool?
//    var hasStage: Bool?
//    var hasGardens: Bool?
//    var hasBasketball: Bool?
//    var hasSkate: Bool?
//    var isReservable: Bool?
//    
//    //var amenities = [[String: AnyObject]]()
//    
//    static func getAll() -> [ParkItem] {
//        var parkItems = [ParkItem]()
//        let parkData = ParkData()
//        
//        if let jsonDataArray = parkData.jsonDataArray {
//            for item in jsonDataArray {
//                
//                if let feature = item.object {
//                    if let parkJSON = feature["attributes"] {
//                        
//                        if let parkName = parkJSON["PARK_NAME"]?.string,
//                            parkAddress = parkJSON["ADDRESS"]?.string,
//                            objectID = parkJSON["OBJECTID"]?.integer {
//                            
//                            var parkItem = ParkItem()
//                            parkItem.parkName = parkName
//                            parkItem.street = parkAddress
//                            parkItem.objectID = objectID
//                            
//                            if let status = parkJSON["STATUS"]?.string {
//                                //parkItem.amenities.append(["Status": status])
//                                parkItem.status = status
//                            }
//                            if let daysOpen = parkJSON["DAYS_OPEN"]?.string {
//                                //parkItem.amenities.append(["Days Open": daysOpen])
//                                parkItem.daysOpen = daysOpen
//                            }
//                            if let hours = parkJSON["HOURS_OF_OPS"]?.string {
//                                //parkItem.amenities.append(["Hours": hours])
//                                parkItem.hours = hours
//                            }
//                            if let parkType = parkJSON["PARK_TYPE"]?.string {
//                                //parkItem.amenities.append(["Park Type": parkType])
//                                parkItem.parkType = parkType
//                            }
//                            if let restrooms = parkJSON["RESTROOMS"]?.string {
//                                //parkItem.amenities.append(["Restrooms": restrooms])
//                                parkItem.hasRestrooms = restrooms == "Yes" ? true : false 
//                            }
//                            if let playEquip = parkJSON["PLAY_EQUIPMENT"]?.string {
//                                //parkItem.amenities.append(["Play Equipment": playEquip])
//                                parkItem.hasPlayEquip = playEquip == "Yes" ? true : false
//                            }
//                            if let picnicTables = parkJSON["PICNIC_TABLES"]?.string {
//                                //parkItem.amenities.append(["Picnic Tables": picnicTables])
//                                parkItem.hasPicnicTables = picnicTables == "Yes" ? true : false
//                            }
//                            if let picnicShelter = parkJSON["PICNIC_SHELTER"]?.string {
//                                //parkItem.amenities.append(["Picnic Shelter": picnicShelter])
//                            }
//                            if let ballfields = parkJSON["BALLFIELDS"]?.string {
//                                //parkItem.amenities.append(["Ballfields": ballfields])
//                            }
//                            if let soccer = parkJSON["SOCCER"]?.string {
//                                //parkItem.amenities.append(["Soccer": soccer])
//                            }
//                            if let jogging = parkJSON["JOGGING"]?.string {
//                                //parkItem.amenities.append(["Jogging": jogging])
//                            }
//                            if let walking = parkJSON["WALKING"]?.string {
//                                //parkItem.amenities.append(["Walking": walking])
//                            }
//                            if let bike = parkJSON["BIKE"]?.string {
//                                //parkItem.amenities.append(["Bike Path": bike])
//                            }
//                            if let multiUseCourt = parkJSON["MULTI_USE_COURT"]?.string {
//                                //parkItem.amenities.append(["Multi-Use Court": multiUseCourt])
//                            }
//                            if let tennis = parkJSON["TENNIS"]?.string {
//                                //parkItem.amenities.append(["Tennis": tennis])
//                            }
//                            if let horseshoes = parkJSON["HORSESHOES"]?.string {
//                                //parkItem.amenities.append(["Horseshoes": horseshoes])
//                            }
//                            if let sprayPad = parkJSON["SPRAY_PAD"]?.string {
//                                //parkItem.amenities.append(["Spray Pad": sprayPad])
//                            }
//                            if let stage = parkJSON["STAGE"]?.string {
//                                //parkItem.amenities.append(["Stage": stage])
//                            }
//                            if let gardens = parkJSON["COMM_GARDENS"]?.string {
//                                //parkItem.amenities.append(["Community Gardens": gardens])
//                            }
//                            if let basketball = parkJSON["BASKETBALL"]?.string {
//                                //parkItem.amenities.append(["Basketball": basketball])
//                            }
//                            if let skate = parkJSON["SKATE"]?.string {
//                                //parkItem.amenities.append(["Skate": skate])
//                            }
//                            if let reservable = parkJSON["RESERVEABLE"]?.string {
//                                //parkItem.amenities.append(["Reservable": reservable])
//                            }
//                            
//                            parkItems.append(parkItem)
//                        }
//                    }
//                }
//                
//            }
//        }
//        
//        return parkItems
//    }
//}