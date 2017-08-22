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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoImage = photoImage {
            scrollView.contentSize = CGSize(width: photoImage.size.width, height: photoImage.size.height)
            photoImageView.image = photoImage
            
            scrollView.maximumZoomScale = 3.0
            scrollView.minimumZoomScale = 1.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
