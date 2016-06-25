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


class Park: NSManagedObject {
    
    static let cloudKitDatabase = CKContainer.defaultContainer().publicCloudDatabase
    static let subscriptionID = "All Parks creations, deletions, and updates"
    
    static var fetchAllFromiCloudQuery: CKQuery {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: CloudKitStrings.Entity.parks, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return query
    }
    
    static func getFetchedResultsController(coreDataStack: CoreDataStack) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(CoreDataStrings.Entity.park, inManagedObjectContext: coreDataStack.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: CoreDataStrings.Attribute.name, ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Error fetching Entry objects: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }
    
    static func fetchAllFromiCloudAndSave(coreDataStack: CoreDataStack) {
        print("fetchAllFromiCloudAndSave")
        cloudKitDatabase.performQuery(fetchAllFromiCloudQuery, inZoneWithID: nil) { (records, error) in
            if error !=  nil {
                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
            } else {
                if let records = records {
                    print("got records from iCloud fetch")
                    // Save to core data
                    Park.save(withRecords: records, coreDataStack: coreDataStack)
                    
                    // Post notification that Cloud fetch and save finished
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.fetchAllFromiCloudAndSaveFinishedNotification, object: nil)
                }
            }
        }
    }
    
    
    static func syncWithiCloud(coreDataStack: CoreDataStack) {
        print("syncWithiCloud called")
        cloudKitDatabase.performQuery(fetchAllFromiCloudQuery, inZoneWithID: nil) { (records, error) in
            if error !=  nil {
                NSLog("Error fetching from iCloud: \(error?.localizedDescription)")
            } else {
                if let records = records {
                    // If have cloud records, just delete all local and re-save
                    deleteAll(coreDataStack)
                    save(withRecords: records, coreDataStack: coreDataStack)
                }
            }
        }
    }
    
    static func save(withRecords records: [CKRecord], coreDataStack: CoreDataStack) {
        for record in records {
            //print(record.objectForKey("name"))
            if let parkName = record.objectForKey(CloudKitStrings.Attribute.name) as? String {
                //print("Name: \(parkName), ID: \(record.recordID.recordName), Zone: \(record.recordID.zoneID)")
                // Fetch recordID from core data, and if it doesn't exist, add it
                if let parkEntity = NSEntityDescription.entityForName(CoreDataStrings.Entity.park, inManagedObjectContext: coreDataStack.managedObjectContext) {
                    let park = Park(entity: parkEntity, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
                    park.name = parkName
                    park.id = record.recordID.recordName
                    park.ckRecordID = record.recordID
                }
            }
        }
        coreDataStack.saveContext()
    }
    
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
    
    static func subscribeToiCloudChanges() {
        print("subscribing to iCloud changes")
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKSubscription(
            recordType: CloudKitStrings.Entity.parks,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.FiresOnRecordUpdate, .FiresOnRecordCreation, .FiresOnRecordDeletion]
        )
        
        cloudKitDatabase.saveSubscription(subscription) { (savedSubscription, error) in
            if error != nil {
                NSLog("iCloud subscription error: \(error?.localizedDescription)")
            }
        }
    }
    
    static func unsubscribeToiCloudChanges() {
        cloudKitDatabase.deleteSubscriptionWithID(subscriptionID) { (subscription, error) in
            if error != nil {
                NSLog("Error deleting iCloud subscription: \(error?.localizedDescription)")
            }
        }
    }
    
    static func updateCoreDataFromiCloudSubscriptionNotification(ckQueryNotification: CKQueryNotification, coreDataStack: CoreDataStack) {
        if ckQueryNotification.subscriptionID == subscriptionID {
//            if let recordID = ckQueryNotification.recordID {
//                switch ckQueryNotification.queryNotificationReason {
//                case .RecordUpdated:
//                    print("record updated")
//                    // remove and add
//                    // TODO: implement this
//                    break
//                case .RecordCreated:
//                    print("record created: recordFields: \()")
//                    if let recordFields = ckQueryNotification.recordFields {
//                        save(withRecordFields: recordFields, coreDataStack: coreDataStack)
//                    }
//                case .RecordDeleted:
//                    print("record deleted")
//                    if let results = fetchParkForRecordID(recordID, coreDataStack: coreDataStack) {
//                        delete(forRecords: results, coreDataStack: coreDataStack)
//                    }
//                }
//            }
            
            //fetchAllFromiCloudAndSave(coreDataStack)
            syncWithiCloud(coreDataStack)
        }
    }
    
    static func fetchParkForRecordID(recordID: CKRecordID, coreDataStack: CoreDataStack) -> [Park]? {
        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
        fetchRequest.predicate = NSPredicate(format: "ckRecordID == %@", recordID)
        do {
            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park]
            return results
        } catch let error as NSError {
            NSLog("Error fetching park record: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static func delete(forRecords records: [Park], coreDataStack: CoreDataStack) {
        for record in records {
            coreDataStack.managedObjectContext.deleteObject(record)
        }
        
        coreDataStack.saveContext()
    }
    
    static func fetchAll(coreDataStack: CoreDataStack) -> [Park]? {
        let fetchRequest = NSFetchRequest(entityName: CoreDataStrings.Entity.park)
        do {
            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Park]
            return results
        } catch let error as NSError {
            NSLog("Error fetching parks: \(error.localizedDescription)")
        }
        
        return nil
    }

}
