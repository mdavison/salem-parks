//
//  DetailViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import YelpAPI

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var amenityImage1: UIImageView! {
        didSet {
            amenityImage1.tintColor = UIColor.lightGrayColor()
        }
    }
    @IBOutlet weak var amenityImage2: UIImageView! {
        didSet {
            amenityImage2.tintColor = UIColor.lightGrayColor()
        }
    }
    @IBOutlet weak var amenityImage3: UIImageView! {
        didSet {
            amenityImage3.tintColor = UIColor.lightGrayColor()
        }
    }
    @IBOutlet weak var amenityImage4: UIImageView! {
        didSet {
            amenityImage4.tintColor = UIColor.lightGrayColor()
        }
    }
    
    var parkItem: ParkItem?
    var ckPark: CKPark? {
        didSet {
            print("ckPark has been set")
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if let imageFileURL = self.ckPark?.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = parkItem?.parkName
        addressLabel.text = parkItem?.street
        
        setAmenityImages()

        if userIsSignedIntoiCloud {
            // Fetch CKPark from cloudkit to populate image
            if let id = parkItem?.objectID {
                //Park.getCKParkFromiCloud(forObjectID: id)
                Park.getCKParkFromiCloud(forObjectID: 48)
            }
            
            // Add observer for when cloud fetch completes
            defaultNotificationCenter.addObserver(
                self,
                selector: #selector(DetailViewController.fetchAllFromiCloudNotificationHandler(_:)),
                name: Notifications.fetchAllFromiCloudFinishedNotification,
                object: nil
            )
        } else {
            if !userHasBeenAlertedToiCloudSignInRequired {
                createiCloudSignInAlert()
            }
        }
        
        // Yelp
        let client = YLPClient(consumerKey: <#T##String#>,
                               consumerSecret: <#T##String#>,
                               token: <#T##String#>,
                               tokenSecret: <#T##String#>)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userIsSignedIntoiCloud {
            Park.unsubscribeToiCloudChanges()
            defaultNotificationCenter.removeObserver(CloudKitNotifications.notificationReceived)
        }
        defaultNotificationCenter.removeObserver(CloudKitNotifications.notSignedIntoiCloudNotification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Notification Handling
    
    @objc private func fetchAllFromiCloudNotificationHandler(notification: NSNotification) {
        print("fetched from iCloud: \(notification.object)")
        if let park = notification.object as? CKPark {
            ckPark = park
        } else if let _ = notification.object as? NSError {
            // iCloud fetch error 
        }
    }
    
    @objc private func notSignedIntoiCloudNotificationHandler(notification: NSNotification) {
        print("not signed into icloud notification handler")
        let alert = UIAlertController(title: "iCloud Error", message: "You will need to sign into iCloud in order to see park photos.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        // TODO: add action that takes user to settings?
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Methods 
    
    private func setAmenityImages() {
        if let restrooms = parkItem?.hasRestrooms where restrooms == true {
            amenityImage1.tintColor = UIColor.blackColor()
        }
        if let picnicTables = parkItem?.hasPicnicTables where picnicTables == true {
            amenityImage2.tintColor = UIColor.blackColor()
        }
        if let picnicShelter = parkItem?.hasPicnicShelter where picnicShelter == true {
            amenityImage3.tintColor = UIColor.blackColor()
        }
        if let playground = parkItem?.hasPlayEquipment where playground == true {
            amenityImage4.tintColor = UIColor.blackColor()
        }
    }
    
    private func createiCloudSignInAlert() {
        let alert = UIAlertController(title: "iCloud Error", message: "You will need to sign into iCloud in order to see any available park photos.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .Default, handler: { (action) in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let _ = settingsUrl {
                //UIApplication.sharedApplication().openURL(url) // This opens the settings for this app, not iCloud
                // Open iCloud Settings
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=CASTLE")!)
            }
        })
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
        userHasBeenAlertedToiCloudSignInRequired = true
    }

}
