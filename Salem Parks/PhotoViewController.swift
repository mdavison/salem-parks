//
//  PhotoViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/9/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photoImage: UIImage?
    var photoIndex: Int?
//    var ckPhotos: [CKPhoto]? {
//        didSet {
//            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                print("ckPhotos were set")
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoImage = photoImage {
            photoImageView.image = photoImage
        }
        
//        if let ckPhotos = ckPhotos {
//            // scroll to photoIndex
//            print("already have ckPhotos: \(ckPhotos.count)")
//        } else {
//            // Add observer for when full sized photos come back
//            NSNotificationCenter.defaultCenter().addObserverForName(
//                Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
//                object: nil,
//                queue: NSOperationQueue.mainQueue(),
//                usingBlock: { [weak self] (notification) in
//                    self?.activityIndicator.hidden = true
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                    
//                    if let _ = notification.object as? NSError {
//                        NSLog("Error downloading large photo")
//                    } else {
//                        if let userInfo = notification.userInfo as? [String: [CKPhoto]], photos = userInfo["Photos"] {
//                            self?.ckPhotos = photos
//                        }
//                    }
//                    
//                })
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Helper Methods
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / photoImageView.bounds.width
        let heightScale = size.height / photoImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }

}


extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
}
