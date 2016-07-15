//
//  PhotoViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/9/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoImage: UIImage?
    var photoIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let photoImage = photoImage {
            photoImageView.image = photoImage
        } else {
            // Add observer for when full sized photos come back
            NSNotificationCenter.defaultCenter().addObserverForName(
                Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
                object: nil,
                queue: NSOperationQueue.mainQueue(),
                usingBlock: { [weak self] (notification) in
                    self?.activityIndicator.hidden = true
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let _ = notification.object as? NSError {
                        NSLog("Error downloading large photo")
                    } else {
                        if let userInfo = notification.userInfo as? [String: [CKPhoto]],
                            photos = userInfo["Photos"], photoIndex = self?.photoIndex {

                            if let imageFileURL = photos[photoIndex].image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
                                self?.photoImageView.image = UIImage(data: data)
                            }
                        }
                    }
                    
            })
        }
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

}
