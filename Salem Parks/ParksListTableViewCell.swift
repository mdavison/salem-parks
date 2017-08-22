//
//  ParksListTableViewCell.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/4/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class ParksListTableViewCell: UITableViewCell {

    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var isFavoriteImageView: UIImageView! {
        didSet {
            isFavoriteImageView.tintColor = Theme.isFavoriteIconColor
        }
    }
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
