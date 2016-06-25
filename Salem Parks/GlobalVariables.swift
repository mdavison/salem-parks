//
//  GlobalVariables.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/24/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation

struct CoreDataStrings {
    struct Entity {
        static let park = "Park"
    }
    
    struct Attribute {
        static let name = "name"
    }
}

struct CloudKitStrings {
    struct Entity {
        static let parks = "Parks"
    }
    
    struct Attribute {
        static let name = "name"
    }
}

struct Notifications {
    static let fetchAllFromiCloudAndSaveFinishedNotification = "FetchAllFromiCloudAndSaveFinishedNotification"
}

struct CloudKitNotifications {
    static let notificationReceived = "iCloudRemoteNotificationReceived"
    static let notificationKey = "Notification"
}
