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

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var amenityImage1: UIImageView! {
        didSet {
            amenityImage1.tintColor = Theme.amenityIconDefaultColor
        }
    }
    @IBOutlet weak var amenityImage2: UIImageView! {
        didSet {
            amenityImage2.tintColor = Theme.amenityIconDefaultColor
        }
    }
    @IBOutlet weak var amenityImage3: UIImageView! {
        didSet {
            amenityImage3.tintColor = Theme.amenityIconDefaultColor
        }
    }
    @IBOutlet weak var amenityImage4: UIImageView! {
        didSet {
            amenityImage4.tintColor = Theme.amenityIconDefaultColor
        }
    }
    
    @IBOutlet weak var ratingStarImage1: UIImageView!
    @IBOutlet weak var ratingStarImage2: UIImageView!
    @IBOutlet weak var ratingStarImage3: UIImageView!
    @IBOutlet weak var ratingStarImage4: UIImageView!
    @IBOutlet weak var ratingStarImage5: UIImageView!
    
    var parkItem: ParkItem?
//    var ckPark: CKPark? {
//        didSet {
//            print("ckPark has been set")
//            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
////                if let imageFileURL = self.ckPark?.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
////                    self.imageView.image = UIImage(data: data)
////                }
//            }
//        }
//    }
    var ckPhotos: [CKPhoto]? {
        didSet {
            //print("ckPhotos has been set")
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                if let firstPhoto = self.ckPhotos?.first {
//                    if let imageFileURL = firstPhoto.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
//                        self.imageView.image = UIImage(data: data)
//                    }
//                }
                self.photosCollectionView.reloadData()
            }
        }
    }
    var parkNetworkActivity = false {
        didSet {
            toggleNetworkActivitySpinner()
        }
    }
    var yelpNetworkActivity = false {
        didSet {
            toggleNetworkActivitySpinner()
        }
    }
    
    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
    
    struct Storyboard {
        static let parkImageCellReuseIdentifier = "ParkImageCell"
        static let amenityCellReuseIdentifier = "AmenityCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = parkItem?.parkName
        addressLabel.text = parkItem?.street
        
        setAmenityImages()
        setParkImages()
        setYelpData()
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
        // Turn off network activity spinner
        parkNetworkActivity = false
        
        //print("fetched from iCloud: \(notification.object)")
//        if let park = notification.object as? CKPark {
//            ckPark = park
//        } else if let _ = notification.object as? NSError {
//            // iCloud fetch error 
//        }
        if let userInfo = notification.userInfo as? [String: [CKPhoto]], photos = userInfo["Photos"] {
//            for photo in photos {
//                print("photo: \(photo.image)")
//            }
            ckPhotos = photos 
        } else if let _ = notification.object as? NSError {
            // iCloud fetch error
        }
    }
    
    @objc private func notSignedIntoiCloudNotificationHandler(notification: NSNotification) {
        let alert = UIAlertController(title: "iCloud Error", message: "You will need to sign into iCloud in order to see park photos.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Methods 
    
    private func setAmenityImages() {
        if let amenities = parkItem?.amenities {
            for amenity in amenities {
                for (key, value) in amenity {
                    switch key {
                    case "Restrooms" where value as? String == "Yes":
                        amenityImage1.tintColor = UIColor.blackColor()
                    case "Picnic Tables" where value as? String == "Yes":
                        amenityImage2.tintColor = UIColor.blackColor()
                    case "Picnic Shelter" where value as? String == "Yes":
                        amenityImage3.tintColor = UIColor.blackColor()
                    case "Play Equipment" where value as? String == "Yes":
                        amenityImage4.tintColor = UIColor.blackColor()
                        
                    default:
                        break;
                    }
                }
            }
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
    
    private func setParkImages() {
        if userIsSignedIntoiCloud {
            // Fetch CKPark from cloudkit to populate image
            if let id = parkItem?.objectID {
                // Turn on network activity spinner
                parkNetworkActivity = true
                
                //Park.getCKParkFromiCloud(forObjectID: id)
                //Park.getCKParkFromiCloud(forObjectID: 48)
                Park.getCKPhotosFromiCloud(forParkID: 48)
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
    }
    
    private func setYelpData() {
        let client = YLPClient(consumerKey: YelpAPIKeys.consumerKey,
                               consumerSecret: YelpAPIKeys.consumerSecret,
                               token: YelpAPIKeys.token,
                               tokenSecret: YelpAPIKeys.tokenSecret)
        
        // Turn on network activity spinner
        yelpNetworkActivity = true
        
        // TODO: get current business id - create plist of all business ids for all parks
        
        client.businessWithId("riverfront-park-salem") { [weak weakSelf = self] (business, error) in
            if let rating = business?.rating {
                dispatch_async(dispatch_get_main_queue(), {
                    //weakSelf?.yelpRatingLabel.text = (weakSelf?.yelpRatingLabel.text)! + " \(rating)/5"
                    weakSelf?.setStarsForRating(rating)
                    
                    // Turn off network activity spinner
                    weakSelf?.yelpNetworkActivity = false
                })
            }
        }
    }
    
    // Coordinate multiple network activity indicators
    private func toggleNetworkActivitySpinner() {
        let sharedApplication = UIApplication.sharedApplication()
        if !userIsSignedIntoiCloud {
            sharedApplication.networkActivityIndicatorVisible = yelpNetworkActivity
        } else {
            if parkNetworkActivity == yelpNetworkActivity {
                sharedApplication.networkActivityIndicatorVisible = !sharedApplication.networkActivityIndicatorVisible
            }
        }
        
    }
    
    private func setStarsForRating(rating: Double) {
        let stars = YelpPark.convertRatingToStarsImages(rating)
        
        if let image1 = stars["image1"], image2 = stars["image2"], image3 = stars["image3"],
            image4 = stars["image4"], image5 = stars["image5"] {
            
            ratingStarImage1.image = UIImage(named: image1)
            ratingStarImage2.image = UIImage(named: image2)
            ratingStarImage3.image = UIImage(named: image3)
            ratingStarImage4.image = UIImage(named: image4)
            ratingStarImage5.image = UIImage(named: image5)
        }
    }

}


extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ckPhotos = ckPhotos where !ckPhotos.isEmpty {
            return ckPhotos.count
        }
        return 1
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.parkImageCellReuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        if let ckPhotos = ckPhotos where !ckPhotos.isEmpty {
            let photo = ckPhotos[indexPath.row]
            if let imageFileURL = photo.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
                cell.photoImageView.image = UIImage(data: data)
            }
        }
        
        return cell 
    }
    
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let amenities = parkItem?.amenities where !amenities.isEmpty {
            return amenities.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.amenityCellReuseIdentifier, forIndexPath: indexPath)
        
        if let amenities = parkItem?.amenities where !amenities.isEmpty {
            let dict = amenities[indexPath.row]
            for (key, value) in dict {
                cell.textLabel?.text = key
                cell.detailTextLabel?.text = value as? String
            }
        } else {
            cell.textLabel?.text = "Error: Unable to fetch park data"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
