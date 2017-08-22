//
//  DetailViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import YelpAPI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            DispatchQueue.main.async { [unowned self] in
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
    
    let defaultNotificationCenter = NotificationCenter.default
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userIsSignedIntoiCloud {
            //Park.unsubscribeToiCloudChanges()
            defaultNotificationCenter.removeObserver(CloudKitNotifications.notificationReceived)
        }
        //defaultNotificationCenter.removeObserver(CloudKitNotifications.notSignedIntoiCloudNotification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Storyboard.showLargePhotoSegueIdentifier {
            if ckPhotos?.count < 1 {
                return false
            }
        }
        
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if let photoViewController = segue.destinationViewController as? PhotoViewController {
        if let photoPageViewController = segue.destination as? PhotoPageViewController {
            // Need to get the collection view item selected
            if let selectedCell = sender as? PhotoCollectionViewCell, let indexPath = photosCollectionView.indexPath(for: selectedCell) {
                // Make sure photo exists
                if ckPhotos?.count > indexPath.item {
//                    if let photo = ckPhotos?[indexPath.item], imageFileURL = photo.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
//                        photoViewController.photoImage = UIImage(data: data)
//                    } else {
//                        // Only have thumbnails so need to get full sized-photos
//                        Park.getCKPhotosFromiCloud(forParkID: park?.id as! Int)
//                        // Set an index so we know which one was selected
//                        photoViewController.photoIndex = indexPath.item
//                        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//                    }
                    
                    // Set the selected photo
                    photoPageViewController.photoIndex = indexPath.item
                    
                    if ckPhotos?[indexPath.item].image != nil {
                        photoPageViewController.ckPhotos = ckPhotos
                    } else {
                        // Only have thumbnails so need to get full sized-photos
                        Park.getCKPhotosFromiCloud(forParkID: park?.id as! Int)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    }
                }
                
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        if park?.isFavorite == true {
            //favoriteButton.setImage(UIImage(named: "Like"), forState: .Normal)
            favoriteButton.changeImageAnimated(UIImage(named: "Like"))
            
            park?.isFavorite = false
        } else { // false or nil
            //favoriteButton.setImage(UIImage(named: "Like Filled"), forState: .Normal)
            favoriteButton.changeImageAnimated(UIImage(named: "Like Filled"))
            park?.isFavorite = true
        }
        
        coreDataStack.saveContext()
    }
    
    @IBAction func openYelp(_ sender: UIButton) {
        if let yelpBusiness = yelpBusiness {
            if let url = YelpPark.getURL(yelpBusiness.identifier) {
                //UIApplication.shared.openURL(url)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Notification Handling
    
    @objc fileprivate func fetchPhotosForParkFromiCloudNotificationHandler(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            // Turn off network activity spinner
            self?.parkNetworkActivity = false
            self?.photosActivityIndicator.isHidden = true
        } 
        
        if let userInfo = notification.userInfo as? [String: [CKPhoto]], let photos = userInfo["Photos"] {
            ckPhotos = photos
        } else if let _ = notification.object as? NSError {
            // iCloud fetch error
        }
    }
    
//    @objc private func notSignedIntoiCloudNotificationHandler(notification: NSNotification) {
//        let alertTitle = NSLocalizedString("iCloud Error", comment: "")
//        let alertMessage = NSLocalizedString("You'll need to sign into iCloud in order to see park photos.", comment: "User needs to sign into iCloud to see photos.")
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
//        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil)
//        alert.addAction(action)
//        
//        presentViewController(alert, animated: true, completion: nil)
//    }
    
    
    // MARK: - Helper Methods 
    
    fileprivate func setAmenityImages() {
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
    
    fileprivate func createiCloudSignInAlert() {
        let alert = UIAlertController(title: "iCloud Error", message: "You will need to sign into iCloud in order to see any available park photos.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        let settingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in            
//            // Open iCloud Settings
//            UIApplication.shared.open(URL(string:"prefs:root=CASTLE")!, options: [:], completionHandler: nil)
//        })
        
        alert.addAction(okAction)
        //alert.addAction(cancelAction)
        //alert.addAction(settingsAction)
        
        present(alert, animated: true, completion: nil)
        
        userHasBeenAlertedToiCloudSignInRequired = true
    }
    
    fileprivate func setFavorite() {
        if park?.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "Like Filled"), for: UIControlState())
        } 
    }
    
    fileprivate func setParkImages() {
        if userIsSignedIntoiCloud {
            // Fetch CKPark from cloudkit to populate image
            if let park = park, let id = park.id as? Int {
                // Turn on network activity spinner
                parkNetworkActivity = true
                photosActivityIndicator.startAnimating()

                Park.getCKPhotosThumbnailsFromiCloud(forParkID: id)
            }
            
            // Add observer for when cloud fetch completes
            defaultNotificationCenter.addObserver(
                self,
                selector: #selector(DetailViewController.fetchPhotosForParkFromiCloudNotificationHandler(_:)),
                name: NSNotification.Name(rawValue: Notifications.fetchPhotosForParkFromiCloudFinishedNotification),
                object: nil
            )
        } else {
            if !userHasBeenAlertedToiCloudSignInRequired {
                createiCloudSignInAlert()
            }
        }
    }
    
    fileprivate func setYelpData() {
        if let park = park, let parkItemID = park.id as? Int, let businessID = YelpPark.getBusinessIDForParkID(parkItemID) {
            // Turn on network activity spinner
            yelpNetworkActivity = true
            
            YLPClient.authorize(withAppId: YelpAPIKeys.clientID, secret: YelpAPIKeys.clientSecret) { (client, error) in
                client?.business(withId: businessID) { [weak self] (business, error) in
                    self?.yelpBusiness = business
                    if let rating = business?.rating {
                        DispatchQueue.main.async {
                            // Set stars
                            self?.setStarsForRating(rating)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            // Turn off network activity spinner
            self.yelpNetworkActivity = false
        }
    }
    
    // Coordinate multiple network activity indicators
    fileprivate func toggleNetworkActivitySpinner() {
        let sharedApplication = UIApplication.shared

        if parkNetworkActivity == false && yelpNetworkActivity == false {
            sharedApplication.isNetworkActivityIndicatorVisible = false
        } else {
            sharedApplication.isNetworkActivityIndicatorVisible = true
        }
    }
    
    fileprivate func setStarsForRating(_ rating: Double) {
        let stars = YelpPark.convertRatingToStarsImages(rating)
        
        if let image1 = stars["image1"], let image2 = stars["image2"], let image3 = stars["image3"],
            let image4 = stars["image4"], let image5 = stars["image5"] {
            
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ckPhotos = ckPhotos, !ckPhotos.isEmpty {
            return ckPhotos.count
        }
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.parkImageCellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        if let ckPhotos = ckPhotos, !ckPhotos.isEmpty {
            let photo = ckPhotos[indexPath.row]
            let imageFileURL = photo.thumbnail?.fileURL ?? photo.image?.fileURL
            if let imageFileURL = imageFileURL, let data = try? Data(contentsOf: imageFileURL) {
                cell.photoImageView.image = UIImage(data: data)
            }
        }
        
        return cell 
    }
    
}


// Amenities Table View
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let amenities = park?.getAmenities(), !amenities.isEmpty {
            return amenities.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.amenityCellReuseIdentifier, for: indexPath)
        
        if let amenities = park?.getAmenities(), !amenities.isEmpty {
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


extension UIButton {
    func changeImageAnimated(_ image: UIImage?) {
        guard let imageView = self.imageView, let currentImage = imageView.image, let newImage = image else {
            return
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.setImage(newImage, for: UIControlState())
        }
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 0.3
        crossFade.fromValue = currentImage.cgImage
        crossFade.toValue = newImage.cgImage
        crossFade.isRemovedOnCompletion = false
        crossFade.fillMode = kCAFillModeForwards
        imageView.layer.add(crossFade, forKey: "animateContents")
        CATransaction.commit()
        
        let crossFadeColor: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFadeColor.duration = 0.3
        crossFadeColor.fromValue = UIColor.black
        crossFadeColor.toValue = Theme.isFavoriteIconColor
        crossFadeColor.isRemovedOnCompletion = false
        crossFadeColor.fillMode = kCAFillModeForwards
        imageView.layer.add(crossFadeColor, forKey: "animateContents")
        CATransaction.commit()
    }
}
