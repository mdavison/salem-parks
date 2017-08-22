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
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator?.stopAnimating()
                if let viewController = self.photoViewController(self.photoIndex ?? 0) {
                    let viewControllers = [viewController]
                    
                    self.setViewControllers(
                        viewControllers,
                        direction: .forward,
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
        view.backgroundColor = UIColor.white
        setActivityIndicator()

        if ckPhotos != nil {
            if let viewController = photoViewController(photoIndex ?? 0) {
                let viewControllers = [viewController]

                setViewControllers(
                    viewControllers,
                    direction: .forward,
                    animated: false,
                    completion: nil
                )
            }
        } else {
            activityIndicator?.startAnimating()
            
            // Add observer for when full sized photos come back
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(rawValue: Notifications.fetchPhotosForParkFromiCloudFinishedNotification),
                object: nil,
                queue: OperationQueue.main,
                using: { [weak self] (notification) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self?.activityIndicator?.startAnimating()
                    
                    if let error = notification.object as? NSError {
                        NSLog("Error downloading large photo: \(error.localizedDescription)")
                        self?.activityIndicator?.stopAnimating()
                    } else {
                        if let userInfo = notification.userInfo as? [String: [CKPhoto]], let photos = userInfo["Photos"] {
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
    
    func photoViewController(_ index: Int) -> PhotoViewController? {
        if let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: Storyboard.photoViewControllerStoryboardID) as? PhotoViewController {
            
            if let photo = ckPhotos?[index], let imageFileURL = photo.image?.fileURL, let data = try? Data(contentsOf: imageFileURL) {
                page.photoImage = UIImage(data: data)
                page.photoIndex = index
                return page
            }
        }
        return nil
    }
    
    fileprivate func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator?.frame = CGRect(
            x: (view.bounds.width / 2) - 25,
            y: (view.bounds.height / 2) - 50,
            width: 50,
            height: 50)
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
    }

}


extension PhotoPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? PhotoViewController {
            var index = viewController.photoIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index! - 1
            return photoViewController(index!)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
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
