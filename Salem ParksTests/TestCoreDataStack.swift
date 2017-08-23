//
//  TestCoreDataStack.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

@testable import Salem_Parks
import CoreData

class TestCoreDataStack: CoreDataStack {
    
    override init() {
        super.init()
        
        self.persistentStoreCoordinator = {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return persistentStoreCoordinator
        }()
    }
    
}
