//
//  Park+CoreDataProperties.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CloudKit

extension Park {

    @NSManaged var name: String?
    @NSManaged var image: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var ckRecordID: CKRecordID?

}
