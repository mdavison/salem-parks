//
//  Park+CoreDataProperties.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/24/16.
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
    @NSManaged var id: String?
    @NSManaged var ckRecordID: CKRecordID?

}
