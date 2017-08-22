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
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    var defaultNotificationCenter = NotificationCenter.default
    let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let tabBarController = window!.rootViewController as! UITabBarController
        let parksListNavController = tabBarController.viewControllers![0] as! UINavigationController
        let parksListViewController = parksListNavController.viewControllers[0] as! ParksListViewController
        parksListViewController.coreDataStack = coreDataStack
        
        let mapViewNavController = tabBarController.viewControllers![1] as! UINavigationController
        let mapViewController = mapViewNavController.viewControllers[0] as! MapViewController
        mapViewController.coreDataStack = coreDataStack
        
        let options: UNAuthorizationOptions = [.alert, .sound];
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                NSLog("User notification request authorization error: \(String(describing: error?.localizedDescription))")
            }
        }
        center.removeAllPendingNotificationRequests();
        
//        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert], categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)
//        UIApplication.shared.cancelAllLocalNotifications()
        
        
        // Determine if user is signed into iCloud
        if let _ = FileManager.default.ubiquityIdentityToken {
            userIsSignedIntoiCloud = true
        }
        
        // Theme
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Theme.navigationTextColor]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }
    
    
    func handleRegionEvent(_ region: CLRegion) {
        if UIApplication.shared.applicationState == .active {
            // Alert near a park
            if let viewController = window?.rootViewController {
                showAlert(withTitle: "Park Nearby!", message: "You are near \(region.identifier).", viewController: viewController)
            }
        } else {
            // Local Notification
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.body = "You are near \(region.identifier)"
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(identifier: "ParkNearbyLocalNotification", content: content, trigger: nil)
            
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Local notification error: \(error)")
                }
            })
            
            
//            let notification = UILocalNotification()
//            notification.alertBody = "You are near \(region.identifier)"
//            notification.soundName = "Default"
//            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if isMonitoringRegions == true && region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }

}

