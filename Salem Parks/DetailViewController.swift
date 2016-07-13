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
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            favoriteButton.tintColor = Theme.isFavoriteIconColor
        }
    }
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var photosActivityIndicator: UIActivityIndicatorView!
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
    
    @IBOutlet weak var ratingStarImage1: UIImageView! {
        didSet {
            ratingStarImage1.tintColor = Theme.ratingStarIconColor
        }
    }
    @IBOutlet weak var ratingStarImage2: UIImageView! {
        didSet {
            ratingStarImage2.tintColor = Theme.ratingStarIconColor
        }
    }
    @IBOutlet weak var ratingStarImage3: UIImageView! {
        didSet {
            ratingStarImage3.tintColor = Theme.ratingStarIconColor
        }
    }
    @IBOutlet weak var ratingStarImage4: UIImageView! {
        didSet {
            ratingStarImage4.tintColor = Theme.ratingStarIconColor
        }
    }
    @IBOutlet weak var ratingStarImage5: UIImageView! {
        didSet {
            ratingStarImage5.tintColor = Theme.ratingStarIconColor
        }
    }
    
    var coreDataStack: CoreDataStack!
    var park: Park?
    var ckPhotos: [CKPhoto]? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
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
    var yelpBusiness: YLPBusiness?
    
    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
    
    struct Storyboard {
        static let parkImageCellReuseIdentifier = "ParkImageCell"
        static let amenityCellReuseIdentifier = "AmenityCell"
        static let showLargePhotoSegueIdentifier = "showLargePhoto"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = park?.name
        addressLabel.text = park?.street
        
        setAmenityImages()
        setFavorite()
        setParkImages()
        setYelpData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userIsSignedIntoiCloud {
            //Park.unsubscribeToiCloudChanges()
            defaultNotificationCenter.removeObserver(CloudKitNotifications.notificationReceived)
        }
        defaultNotificationCenter.removeObserver(CloudKitNotifications.notSignedIntoiCloudNotification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.showLargePhotoSegueIdentifier {
            if ckPhotos?.count < 1 {
                return false
            }
        }
        
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let photoViewController = segue.destinationViewController as? PhotoViewController {
            // Need to get the collection view item selected
            if let selectedCell = sender as? PhotoCollectionViewCell, indexPath = photosCollectionView.indexPathForCell(selectedCell) {
                // Make sure photo exists
                if ckPhotos?.count > indexPath.item {
                    if let photo = ckPhotos?[indexPath.item], imageFileURL = photo.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
                        photoViewController.photoImage = UIImage(data: data)
                    }
                }
                
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func toggleFavorite(sender: UIButton) {
        if park?.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "Like"), forState: .Normal)
            park?.isFavorite = false
        } else { // false or nil
            favoriteButton.setImage(UIImage(named: "Like Filled"), forState: .Normal)
            park?.isFavorite = true
        }
        
        coreDataStack.saveContext()
    }
    
    @IBAction func openYelp(sender: UIButton) {
        if let yelpBusiness = yelpBusiness {
            if let url = YelpPark.getURL(yelpBusiness.identifier) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    // MARK: - Notification Handling
    
    @objc private func fetchPhotosForParkFromiCloudNotificationHandler(notification: NSNotification) {
        // Turn off network activity spinner
        parkNetworkActivity = false
        photosActivityIndicator.hidden = true 
        
        if let userInfo = notification.userInfo as? [String: [CKPhoto]], photos = userInfo["Photos"] {
            ckPhotos = photos
        } else if let _ = notification.object as? NSError {
            // iCloud fetch error
        }
    }
    
    @objc private func notSignedIntoiCloudNotificationHandler(notification: NSNotification) {
        let alertTitle = NSLocalizedString("iCloud Error", comment: "")
        let alertMessage = NSLocalizedString("You'll need to sign into iCloud in order to see park photos.", comment: "User needs to sign into iCloud to see photos.")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Methods 
    
    private func setAmenityImages() {
        if park?.hasRestrooms == true {
            amenityImage1.tintColor = Theme.amenityIconHighlightColor
        }
        if park?.hasPicnicTables == true {
            amenityImage2.tintColor = Theme.amenityIconHighlightColor
        }
        if park?.hasPicnicShelter == true {
            amenityImage3.tintColor = Theme.amenityIconHighlightColor
        }
        if park?.hasPlayEquip == true {
            amenityImage4.tintColor = Theme.amenityIconHighlightColor
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
    
    private func setFavorite() {
        if park?.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "Like Filled"), forState: .Normal)
        } 
    }
    
    private func setParkImages() {
        if userIsSignedIntoiCloud {
            // Fetch CKPark from cloudkit to populate image
            if let park = park, id = park.id as? Int {
                // Turn on network activity spinner
                parkNetworkActivity = true
                photosActivityIndicator.hidden = false

                Park.getCKPhotosFromiCloud(forParkID: id)
            }
            
            // Add observer for when cloud fetch completes
            defaultNotificationCenter.addObserver(
                self,
                selector: #selector(DetailViewController.fetchPhotosForParkFromiCloudNotificationHandler(_:)),
                name: Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
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
        
        if let park = park, parkItemID = park.id as? Int, businessID = YelpPark.getBusinessIDForParkID(parkItemID) {
            // Turn on network activity spinner
            yelpNetworkActivity = true
            
            client.businessWithId(businessID) { [weak self] (business, error) in
                self?.yelpBusiness = business
                if let rating = business?.rating {
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.setStarsForRating(rating)
                    })
                }
                
                // Turn off network activity spinner
                self?.yelpNetworkActivity = false
            }
        }
    }
    
    // Coordinate multiple network activity indicators
    private func toggleNetworkActivitySpinner() {
        let sharedApplication = UIApplication.sharedApplication()

        if parkNetworkActivity == false && yelpNetworkActivity == false {
            sharedApplication.networkActivityIndicatorVisible = false
        } else {
            sharedApplication.networkActivityIndicatorVisible = true
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


// Photos Collection View
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


// Amenities Table View
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let amenities = park?.getAmenities() where !amenities.isEmpty {
            return amenities.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.amenityCellReuseIdentifier, forIndexPath: indexPath)
        
        if let amenities = park?.getAmenities() where !amenities.isEmpty {
            let dict = amenities[indexPath.row]
            for (key, value) in dict {
                cell.textLabel?.text = key
                cell.detailTextLabel?.text = value
            }
        } else {
            cell.textLabel?.text = "Error: Unable to fetch park data"
            cell.detailTextLabel?.text = ""
        }
                
        return cell
    }
}
