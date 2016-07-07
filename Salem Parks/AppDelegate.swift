//
//  AppDelegate.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    var defaultNotificationCenter = NSNotificationCenter.defaultCenter()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let tabBarController = window!.rootViewController as! UITabBarController
        let parksListNavController = tabBarController.viewControllers![0] as! UINavigationController
        let parksListTableViewController = parksListNavController.viewControllers[0] as! ParksListTableViewController
        parksListTableViewController.coreDataStack = coreDataStack
        
        let mapViewNavController = tabBarController.viewControllers![1] as! UINavigationController
        let mapViewController = mapViewNavController.viewControllers[0] as! MapViewController
        mapViewController.coreDataStack = coreDataStack
        
        let settings = UIUserNotificationSettings(forTypes: [.Badge], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Determine if user is signed into iCloud
        if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            userIsSignedIntoiCloud = true
        }
        
        // Theme
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Theme.navigationTextColor]
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken called: \(deviceToken.bytes)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        print("didFailToRegisterForRemoteNotificationsWithError error: \(error.localizedDescription)")
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        print("recieved remote notification")
//        let cloudKitQueryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
//        let notification = NSNotification(
//            name: CloudKitNotifications.notificationReceived,
//            object: self,
//            userInfo: [CloudKitNotifications.notificationKey: cloudKitQueryNotification]
//        )
//        
//        NSNotificationCenter.defaultCenter().postNotification(notification)
//    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("recieved remote notification")
        let cloudKitQueryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        let notification = NSNotification(
            name: CloudKitNotifications.notificationReceived,
            object: self,
            userInfo: [CloudKitNotifications.notificationKey: cloudKitQueryNotification]
        )
        
        defaultNotificationCenter.postNotification(notification)
        
        completionHandler(.NewData)

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }

}

