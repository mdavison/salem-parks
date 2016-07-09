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
    
    var photoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let photoImage = photoImage {
            photoImageView.image = photoImage
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
