//
//  Park+CoreDataProperties.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/2/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Park {

    @NSManaged var id: NSNumber?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var name: String?
    @NSManaged var street: String?
    @NSManaged var status: String?
    @NSManaged var daysOpen: String?
    @NSManaged var hours: String?
    @NSManaged var parkType: String?
    @NSManaged var hasRestrooms: NSNumber?
    @NSManaged var hasPlayEquip: NSNumber?
    @NSManaged var hasPicnicTables: NSNumber?
    @NSManaged var hasPicnicShelter: NSNumber?
    @NSManaged var hasBallfields: NSNumber?
    @NSManaged var hasSoccer: NSNumber?
    @NSManaged var hasJogging: NSNumber?
    @NSManaged var hasWalking: NSNumber?
    @NSManaged var hasBike: NSNumber?
    @NSManaged var hasMultiUseCourt: NSNumber?
    @NSManaged var hasTennis: NSNumber?
    @NSManaged var hasHorseshoes: NSNumber?
    @NSManaged var hasSprayPad: NSNumber?
    @NSManaged var hasStage: NSNumber?
    @NSManaged var hasGardens: NSNumber?
    @NSManaged var hasBasketball: NSNumber?
    @NSManaged var hasSkate: NSNumber?
    @NSManaged var isReservable: NSNumber?

}
