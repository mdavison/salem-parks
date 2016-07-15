//
//  GlobalVariables.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/24/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

var userIsSignedIntoiCloud = false
var userHasBeenAlertedToiCloudSignInRequired = false
var isMonitoringRegions = false 

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
        static let image = "image"
        static let parkID = "parkID"
        static let thumbnail = "thumbnail"
        static let fileName = "fileName"
        static let displayOrder = "displayOrder"
    }
}

struct Notifications {
    //static let fetchAllFromiCloudAndSaveFinishedNotification = "FetchAllFromiCloudAndSaveFinishedNotification"
    static let fetchPhotosForParkFromiCloudFinishedNotification = "FetchPhotosForParkFromiCloudFinishedNotification"
    static let getParkForCKRecordIDFinishedNotification = "GetParkForCKRecordIDFinishedNotification"
}

struct CloudKitNotifications {
    static let notificationReceived = "iCloudRemoteNotificationReceived"
    static let notificationKey = "Notification"
    static let notSignedIntoiCloudNotification = "notSignedIntoiCloudNotification"
    //static let hasNewPhotosFinishedNotification = "HasNewPhotosFinishedNotification"
}

func showAlert(withTitle title: String, message: String, viewController: UIViewController) {
    if viewController.presentedViewController == nil { // Prevent multiple alerts at the same time
        let localizedTitle = NSLocalizedString(title, comment: "")
        let localizedMessage = NSLocalizedString(message, comment: "")
        let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}
