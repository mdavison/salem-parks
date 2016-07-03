//
//  GlobalVariables.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/24/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation

var userIsSignedIntoiCloud = false
var userHasBeenAlertedToiCloudSignInRequired = false 

struct CoreDataStrings {
    struct Entity {
        static let park = "Park"
    }
    
    struct Attribute {
        static let id = "id"
        static let name = "name"
        static let isFavorite = "isFavorite"
        static let street = "street"
        static let status = "status"
    }
}

struct CloudKitStrings {
    struct Entity {
        static let parks = "Parks"
        static let photos = "Photos"
    }
    
    struct Attribute {
        static let name = "name"
        static let image = "image"
        static let id = "id"
    }
}

struct Notifications {
    //static let fetchAllFromiCloudAndSaveFinishedNotification = "FetchAllFromiCloudAndSaveFinishedNotification"
    static let fetchAllFromiCloudFinishedNotification = "FetchAllFromiCloudFinishedNotification"
}

struct CloudKitNotifications {
    static let notificationReceived = "iCloudRemoteNotificationReceived"
    static let notificationKey = "Notification"
    static let notSignedIntoiCloudNotification = "notSignedIntoiCloudNotification"
}
