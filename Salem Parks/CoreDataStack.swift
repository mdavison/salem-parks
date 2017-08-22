//
//  CoreDataStack.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let modelName = "Salem_Parks"
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.morgandavison.Salem_Parks" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(self.modelName).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
//            let options =
//                [NSPersistentStoreUbiquitousContentNameKey: "SalemParks",
//                 NSMigratePersistentStoresAutomaticallyOption: true,
//                 NSInferMappingModelAutomaticallyOption: true] as [String : Any]
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK: - iCloud Sync
    
//    var updateContextWithUbiquitousContentUpdates: Bool = false {
//        willSet {
//            ubiquitousChangesObserver = newValue ? NotificationCenter.default : nil
//        }
//    }
//    
//    fileprivate var ubiquitousChangesObserver: NotificationCenter? {
//        didSet {
//            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: persistentStoreCoordinator)
//            
//            ubiquitousChangesObserver?.addObserver(
//                self,
//                selector: #selector(CoreDataStack.persistentStoreDidImportUbiquitousContentChanges(_:)),
//                name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges,
//                object: persistentStoreCoordinator)
//            
//            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: persistentStoreCoordinator)
//            
//            ubiquitousChangesObserver?.addObserver(
//                self,
//                selector: #selector(CoreDataStack.persistentStoreCoordinatorWillChangeStores(_:)),
//                name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange,
//                object: persistentStoreCoordinator)
//        }
//    }
//    
//    @objc func persistentStoreDidImportUbiquitousContentChanges(_ notification: Notification) {
//        NSLog("Merging ubiquitous content changes")
//        managedObjectContext.perform {
//            self.managedObjectContext.mergeChanges(fromContextDidSave: notification)
//        }
//    }
//    
//    @objc func persistentStoreCoordinatorWillChangeStores(_ notification: Notification) {
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch let error as NSError {
//                print("Error saving \(error)", terminator: "")
//            }
//        }
//        managedObjectContext.reset()
//    }
    
}
