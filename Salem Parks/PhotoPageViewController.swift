//
//  PhotoPageViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/15/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class PhotoPageViewController: UIPageViewController {

    var activityIndicator: UIActivityIndicatorView?
    var photoIndex: Int?
    var ckPhotos: [CKPhoto]? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.activityIndicator?.stopAnimating()
                if let viewController = self.photoViewController(self.photoIndex ?? 0) {
                    let viewControllers = [viewController]
                    
                    self.setViewControllers(
                        viewControllers,
                        direction: .Forward,
                        animated: false,
                        completion: nil
                    )
                }
            }
        }
    }
    
    struct Storyboard {
        static let photoViewControllerStoryboardID = "PhotoViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        view.backgroundColor = UIColor.whiteColor()
        setActivityIndicator()

        if ckPhotos != nil {
            if let viewController = photoViewController(photoIndex ?? 0) {
                let viewControllers = [viewController]

                setViewControllers(
                    viewControllers,
                    direction: .Forward,
                    animated: false,
                    completion: nil
                )
            }
        } else {
            // Add observer for when full sized photos come back
            NSNotificationCenter.defaultCenter().addObserverForName(
                Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
                object: nil,
                queue: NSOperationQueue.mainQueue(),
                usingBlock: { [weak self] (notification) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let _ = notification.object as? NSError {
                        NSLog("Error downloading large photo")
                    } else {
                        if let userInfo = notification.userInfo as? [String: [CKPhoto]], photos = userInfo["Photos"] {
                            self?.ckPhotos = photos
                        }
                    }
                    
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Helper Methods
    
    func photoViewController(index: Int) -> PhotoViewController? {
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier(Storyboard.photoViewControllerStoryboardID) as? PhotoViewController {

            if let photo = ckPhotos?[index], imageFileURL = photo.image?.fileURL, data = NSData(contentsOfURL: imageFileURL) {
                page.photoImage = UIImage(data: data)
                page.photoIndex = index
                return page
            }
        }
        return nil
    }
    
    private func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator!.frame = CGRect(
            x: (view.bounds.width / 2) - 25,
            y: (view.bounds.height / 2) - 50,
            width: 50,
            height: 50)
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.startAnimating()
        view.addSubview(activityIndicator!)
    }

}


extension PhotoPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? PhotoViewController {
            var index = viewController.photoIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index! - 1
            return photoViewController(index!)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? PhotoViewController {
            var index = viewController.photoIndex
            guard index != NSNotFound else { return nil }
            index = index! + 1
            guard index != ckPhotos!.count else {return nil}
            return photoViewController(index!)
        }
        
        return nil
    }
    
}
