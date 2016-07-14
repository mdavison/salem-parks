//
//  Park.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import MapKit

class Park: NSManagedObject {
    
    static let cloudKitDatabase = CKContainer.defaultContainer().publicCloudDatabase
    static let subscriptionID = "All park photos creations, deletions, and updates"
    static var fetchAllFromiCloudQuery: CKQuery {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: CloudKitStrings.Entity.parks, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return query
    }
    
    static func getAll(coreDataStack: CoreDataStack) -> [Park]? {
        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
        do {
            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park]
            return results
        } catch let error as NSError {
            NSLog("Error fetching parks: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static func getFetchedResultsController(searchText: String?, coreDataStack: CoreDataStack) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(CoreDataStrings.Entity.park, inManagedObjectContext: coreDataStack.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Predicate
        if let searchText = searchText {
            fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", searchText)
        }
        
        // Edit the sort key as appropriate.
        let favSortDescriptor = NSSortDescriptor(key: CoreDataStrings.Attribute.isFavorite, ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: CoreDataStrings.Attribute.name, ascending: true)
        
        fetchRequest.sortDescriptors = [favSortDescriptor, nameSortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Error fetching Entry objects: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }
    
    static func getPark(forID id: Int, coreDataStack: CoreDataStack) -> Park? {
        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        
        do {
            if let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park] {
                return results.first
            }
            
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
        
        return nil 
    }
    
//    static func getPark(forCKRecordID ckRecordID: CKRecordID, coreDataStack: CoreDataStack) {
//        cloudKitDatabase.fetchRecordWithID(ckRecordID) { (record, error) in
//            if let record = record {
//                //print("got records from iCloud fetch: count: \(records.count)")
//                print("ckRecord for ckRecordID: \(record.objectForKey(CloudKitStrings.Attribute.parkID))")
//                if let id = record.objectForKey(CloudKitStrings.Attribute.parkID) as? Int {
//                    if let park = Park.getPark(forID: id, coreDataStack: coreDataStack) {
//                        NSNotificationCenter.defaultCenter().postNotificationName(
//                            Notifications.getParkForCKRecordIDFinishedNotification,
//                            object: self,
//                            userInfo: ["Park": park])
//                    }
//                }
//            }
//        }
//    }
    
    static func saveJSONDataToCoreData(coreDataStack: CoreDataStack) {
        let parkData = ParkData()
        
        if let jsonDataArray = parkData.jsonDataArray {
            for item in jsonDataArray {
                
                if let feature = item.object {
                    if let parkJSON = feature["attributes"] {
                        
                        if let parkName = parkJSON["PARK_NAME"]?.string,
                            parkAddress = parkJSON["ADDRESS"]?.string,
                            objectID = parkJSON["OBJECTID"]?.integer {
                            
                            if let parkEntity = NSEntityDescription.entityForName(CoreDataStrings.Entity.park, inManagedObjectContext: coreDataStack.managedObjectContext) {
                            
                                let park = Park(entity: parkEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
                                park.name = parkName
                                park.street = parkAddress
                                park.id = objectID
                                
                                if let status = parkJSON["STATUS"]?.string {
                                    park.status = status
                                }
                                if let daysOpen = parkJSON["DAYS_OPEN"]?.string {
                                    park.daysOpen = daysOpen
                                }
                                if let hours = parkJSON["HOURS_OF_OPS"]?.string {
                                    park.hours = hours
                                }
                                if let parkType = parkJSON["PARK_TYPE"]?.string {
                                    park.parkType = parkType
                                }
                                if let restrooms = parkJSON["RESTROOMS"]?.string {
                                    park.hasRestrooms = restrooms == "Yes" ? true : false
                                }
                                if let playEquip = parkJSON["PLAY_EQUIPMENT"]?.string {
                                    park.hasPlayEquip = playEquip == "Yes" ? true : false
                                }
                                if let picnicTables = parkJSON["PICNIC_TABLES"]?.string {
                                    park.hasPicnicTables = picnicTables == "Yes" ? true : false
                                }
                                if let picnicShelter = parkJSON["PICNIC_SHELTER"]?.string {
                                    park.hasPicnicShelter = picnicShelter == "Yes" ? true : false
                                }
                                if let ballfields = parkJSON["BALLFIELDS"]?.string {
                                    park.hasBallfields = ballfields == "Yes" ? true : false
                                }
                                if let soccer = parkJSON["SOCCER"]?.string {
                                    park.hasSoccer = soccer == "Yes" ? true : false
                                }
                                if let jogging = parkJSON["JOGGING"]?.string {
                                    park.hasJogging = jogging == "Yes" ? true : false
                                }
                                if let walking = parkJSON["WALKING"]?.string {
                                    park.hasWalking = walking == "Yes" ? true : false
                                }
                                if let bike = parkJSON["BIKE"]?.string {
                                    park.hasBike = bike == "Yes" ? true : false
                                }
                                if let multiUseCourt = parkJSON["MULTI_USE_COURT"]?.string {
                                    park.hasMultiUseCourt = multiUseCourt == "Yes" ? true : false
                                }
                                if let tennis = parkJSON["TENNIS"]?.string {
                                    park.hasTennis = tennis == "Yes" ? true : false
                                }
                                if let horseshoes = parkJSON["HORSESHOES"]?.string {
                                    park.hasHorseshoes = horseshoes == "Yes" ? true : false
                                }
                                if let sprayPad = parkJSON["SPRAY_PAD"]?.string {
                                    park.hasSprayPad = sprayPad == "Yes" ? true : false
                                }
                                if let stage = parkJSON["STAGE"]?.string {
                                    park.hasStage = stage == "Yes" ? true : false
                                }
                                if let gardens = parkJSON["COMM_GARDENS"]?.string {
                                    park.hasGardens = gardens == "Yes" ? true : false
                                }
                                if let basketball = parkJSON["BASKETBALL"]?.string {
                                    park.hasBasketball = basketball == "Yes" ? true : false
                                }
                                if let skate = parkJSON["SKATE"]?.string {
                                    park.hasSkate = skate == "Yes" ? true : false
                                }
                                if let reservable = parkJSON["RESERVEABLE"]?.string {
                                    park.isReservable = reservable == "Yes" ? true : false
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        coreDataStack.saveContext()
    }
    
    
//    static func getCKParkFromiCloud(forObjectID id: Int) {
//        let predicate = NSPredicate(format: "id == %d", id)
//        let query = CKQuery(recordType: CloudKitStrings.Entity.parks, predicate: predicate)
//        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        
//        cloudKitDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
//            if error !=  nil {
//                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
//                
//                // Post notification that iCloud fetched but got error
//                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchAllFromiCloudFinishedNotification, object: error)
//            } else {
//                if let records = records, record = records.first {
//                    //print("got records from iCloud fetch: count: \(records.count)")
//                    if let parkName = record.objectForKey(CloudKitStrings.Attribute.name) as? String,
//                        id = record.objectForKey(CloudKitStrings.Attribute.id) as? Int {
//                        
//                        let park = CKPark()
//                        park.name = parkName
//                        park.id = id
//                        park.ckRecordID = record.recordID
//
//                        // Post notification that Cloud fetch finished
//                        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchAllFromiCloudFinishedNotification, object: park)
//                    }
//                }
//            }
//        }
//    }
    
    static func getCKPhotosFromiCloud(forParkID id: Int) {
        let predicate = NSPredicate(format: "parkID == %d", id)
        
        let query = CKQuery(recordType: CloudKitStrings.Entity.photos, predicate: predicate)
        //query.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        cloudKitDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if error !=  nil {
                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
                
                // Post notification that iCloud fetched but got error
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchPhotosForParkFromiCloudFinishedNotification, object: error)
            } else {
                if let records = records {
                    //print("got records from iCloud fetch: count: \(records.count)")
                    var ckPhotos = [CKPhoto]()
                    
                    for record in records {
                        if let image = record.objectForKey(CloudKitStrings.Attribute.image) as? CKAsset {
                            let ckPhoto = CKPhoto()
                            ckPhoto.image = image 
                            ckPhotos.append(ckPhoto)
                        }
                    }
                    // Post notification that Cloud fetch finished
                    //NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchAllFromiCloudFinishedNotification, object: ckPhotos as? AnyObject)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
                        object: self,
                        userInfo: ["Photos": ckPhotos])
                }
            }
        }
    }
    
    static func getRegions(forAnnotations annotations: [ParkAnnotation], currentLocation: CLLocation) -> [CLCircularRegion] {
        var regions = [CLCircularRegion]()
        
        // Sort the annotations according to coordinate
        var annotationLocations = [ParkAnnotation: CLLocationDistance]()
        // Get all the distances in dictionary
        for annotation in annotations {
            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let distance = annotationLocation.distanceFromLocation(currentLocation)
            annotationLocations[annotation] = distance
        }
        // Sort the dictionary and just take the first 20
        let sortedKeys = Array(annotationLocations.keys).sort({annotationLocations[$0] < annotationLocations[$1]}).prefix(20)
        
        for annotation in sortedKeys {
            let coordinate = annotation.coordinate
            let title = annotation.title ?? ""
            let region = CLCircularRegion(center: coordinate, radius: 500, identifier: title)
            regions.append(region)
            
//            if annotation.locationName == "1490 Doaks Ferry Rd NW" {
//                regions.append(region)
//            }
        }
        
        return regions
    }
    
//    static func fetchAllFromiCloudAndSave(coreDataStack: CoreDataStack) {
//        print("fetchAllFromiCloudAndSave")
//        cloudKitDatabase.performQuery(fetchAllFromiCloudQuery, inZoneWithID: nil) { (records, error) in
//            if error !=  nil {
//                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
//            } else {
//                if let records = records {
//                    print("got records from iCloud fetch")
//                    // Save to core data
//                    Park.save(withRecords: records, coreDataStack: coreDataStack)
//                    
//                    // Post notification that Cloud fetch and save finished
//                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchAllFromiCloudAndSaveFinishedNotification, object: nil)
//                }
//            }
//        }
//    }
    
    
//    static func syncWithiCloud(coreDataStack: CoreDataStack) {
//        print("syncWithiCloud called")
//        cloudKitDatabase.performQuery(fetchAllFromiCloudQuery, inZoneWithID: nil) { (records, error) in
//            if error !=  nil {
//                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
//            } else {
//                if let records = records {
//                    // If have cloud records, just delete all local and re-save
//                    deleteAll(coreDataStack)
//                    save(withRecords: records, coreDataStack: coreDataStack)
//                }
//            }
//        }
//    }
    
//    static func save(withRecords records: [CKRecord], coreDataStack: CoreDataStack) {
//        for record in records {
//            //print(record.objectForKey("name"))
//            if let parkName = record.objectForKey(CloudKitStrings.Attribute.name) as? String {
//                //print("Name: \(parkName), ID: \(record.recordID.recordName), Zone: \(record.recordID.zoneID)")
//                // Fetch recordID from core data, and if it doesn't exist, add it
//                if let parkEntity = NSEntityDescription.entityForName(CoreDataStrings.Entity.park, inManagedObjectContext: coreDataStack.managedObjectContext) {
//                    let park = Park(entity: parkEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
//                    park.name = parkName
//                    park.ckRecordID = record.recordID
//                }
//            }
//        }
//        coreDataStack.saveContext()
//    }
    
    static func deleteAll(coreDataStack: CoreDataStack) {
        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
        
        do {
            if let parks = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park] {
                for park in parks {
                    //print("Deleting object: \(park)")
                    coreDataStack.managedObjectContext.deleteObject(park)
                }
            }
        } catch let error as NSError {
            NSLog("Error deleting Parks from Core Data: \(error) " + " Description: \(error.localizedDescription)")
        }
        
        print("deleted all records from core data")
        coreDataStack.saveContext()
    }
    
//    static func subscribeToiCloudChanges() {
//        print("subscribing to iCloud changes")
//        let predicate = NSPredicate(format: "TRUEPREDICATE")
//        let subscription = CKSubscription(
//            recordType: CloudKitStrings.Entity.photos,
//            predicate: predicate,
//            subscriptionID: subscriptionID,
//            options: [.FiresOnRecordCreation]
//        )
//        let info = CKNotificationInfo()
//        info.shouldBadge = true
//        subscription.notificationInfo = info 
//        
//        cloudKitDatabase.saveSubscription(subscription) { (savedSubscription, error) in
//            if error != nil {
//                NSLog("iCloud subscription error: \(error?.localizedDescription)")
//            }
//        }
//    }
    
//    static func unsubscribeToiCloudChanges() {
//        cloudKitDatabase.deleteSubscriptionWithID(subscriptionID) { (subscription, error) in
//            if error != nil {
//                NSLog("Error deleting iCloud subscription: \(error?.localizedDescription)")
//            }
//        }
//    }
    
    
//    static func updateCoreDataFromiCloudSubscriptionNotification(ckQueryNotification: CKQueryNotification, coreDataStack: CoreDataStack) {
//        if ckQueryNotification.subscriptionID == subscriptionID {
////            if let recordID = ckQueryNotification.recordID {
////                switch ckQueryNotification.queryNotificationReason {
////                case .RecordUpdated:
////                    print("record updated")
////                    // remove and add
////                    // TODO: implement this
////                    break
////                case .RecordCreated:
////                    print("record created: recordFields: \()")
////                    if let recordFields = ckQueryNotification.recordFields {
////                        save(withRecordFields: recordFields, coreDataStack: coreDataStack)
////                    }
////                case .RecordDeleted:
////                    print("record deleted")
////                    if let results = fetchParkForRecordID(recordID, coreDataStack: coreDataStack) {
////                        delete(forRecords: results, coreDataStack: coreDataStack)
////                    }
////                }
////            }
//            
//            //fetchAllFromiCloudAndSave(coreDataStack)
//            syncWithiCloud(coreDataStack)
//        }
//    }
    
//    static func fetchParkForRecordID(recordID: CKRecordID, coreDataStack: CoreDataStack) -> [Park]? {
//        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
//        fetchRequest.predicate = NSPredicate(format: "ckRecordID == %@", recordID)
//        do {
//            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park]
//            return results
//        } catch let error as NSError {
//            NSLog("Error fetching park record: \(error.localizedDescription)")
//        }
//        
//        return nil
//    }
    
//    static func delete(forRecords records: [Park], coreDataStack: CoreDataStack) {
//        for record in records {
//            coreDataStack.managedObjectContext.deleteObject(record)
//        }
//        
//        coreDataStack.saveContext()
//    }
    
    
    func getAmenities() -> [[String: String?]] {
        let amenities = [
            ["Status": status],
            ["Days Open": daysOpen],
            ["Hours": hours],
            ["Park Type": parkType],
            ["Restrooms": hasRestrooms == true ? "Yes" : "No"],
            ["Play Equipment": hasPlayEquip == true ? "Yes" : "No"],
            ["Picnic Tables": hasPicnicTables == true ? "Yes" : "No"],
            ["Picnic Shelter": hasPicnicShelter == true ? "Yes" : "No"],
            ["Ballfields": hasBallfields == true ? "Yes" : "No"],
            ["Soccer": hasSoccer == true ? "Yes" : "No"],
            ["Jogging": hasJogging == true ? "Yes" : "No"],
            ["Walking": hasWalking == true ? "Yes" : "No"],
            ["Bike Path": hasBike == true ? "Yes" : "No"],
            ["Multi Use Court": hasMultiUseCourt == true ? "Yes" : "No"],
            ["Tennis": hasTennis == true ? "Yes" : "No"],
            ["Horseshoes": hasHorseshoes == true ? "Yes" : "No"],
            ["Spray Pad": hasSprayPad == true ? "Yes" : "No"],
            ["Stage": hasStage == true ? "Yes" : "No"],
            ["Community Gardens": hasGardens == true ? "Yes" : "No"],
            ["Basketball": hasBasketball == true ? "Yes" : "No"],
            ["Skate": hasSkate == true ? "Yes" : "No"],
            ["Reservable": isReservable == true ? "Yes" : "No"]
        ]

        return amenities
    }
    

}
