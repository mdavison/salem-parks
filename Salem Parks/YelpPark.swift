//
//  YelpPark.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/30/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

struct YelpPark {
    static func convertRatingToStarsImages(_ rating: Double) -> [String: String] {
        struct ImageNames {
            static let star = "Star"
            static let starFilled = "Star Filled"
            static let starHalfEmpty = "Star Half Empty"
        }
        struct ImageReferences {
            static let image1 = "image1"
            static let image2 = "image2"
            static let image3 = "image3"
            static let image4 = "image4"
            static let image5 = "image5"
        }
        var starsImages = [String: String]()
        
        switch rating {
        case 1.0:
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.star,
                ImageReferences.image3: ImageNames.star,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        case 2.0:
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.star,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        case 3.0:
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starFilled,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        case 4.0:
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starFilled,
                ImageReferences.image4: ImageNames.starFilled,
                ImageReferences.image5: ImageNames.star
            ]
        case 5.0:
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starFilled,
                ImageReferences.image4: ImageNames.starFilled,
                ImageReferences.image5: ImageNames.starFilled
            ]
        default:
            break
        }
        
        if rating > 0 && rating < 1.0 { // .5 stars
            starsImages = [
                ImageReferences.image1: ImageNames.starHalfEmpty,
                ImageReferences.image2: ImageNames.star,
                ImageReferences.image3: ImageNames.star,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        } else if rating > 1.0 && rating < 2.0 { // 1.5 stars
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starHalfEmpty,
                ImageReferences.image3: ImageNames.star,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        } else if rating > 2.0 && rating < 3.0 { // 2.5 stars
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starHalfEmpty,
                ImageReferences.image4: ImageNames.star,
                ImageReferences.image5: ImageNames.star
            ]
        } else if rating > 3.0 && rating < 4.0 { // 3.5 stars
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starFilled,
                ImageReferences.image4: ImageNames.starHalfEmpty,
                ImageReferences.image5: ImageNames.star
            ]
        } else if rating > 4.0 && rating < 5.0 { // 4.5 stars
            starsImages = [
                ImageReferences.image1: ImageNames.starFilled,
                ImageReferences.image2: ImageNames.starFilled,
                ImageReferences.image3: ImageNames.starFilled,
                ImageReferences.image4: ImageNames.starFilled,
                ImageReferences.image5: ImageNames.starHalfEmpty
            ]
        }

        return starsImages
    }
    
    
    static func getBusinessIDForParkID(_ parkID: Int) -> String? {
        if let path = Bundle.main.path(forResource: "Yelp", ofType: "plist") {
            if let parks = NSDictionary(contentsOfFile: path) {
                if let businessID = parks.object(forKey: "\(parkID)") as AnyObject? {
                    return businessID.object(forKey: "businessID") as? String
                }
                return nil
            }
        }
        return nil
    }
    
    static func yelpIsInstalled() -> Bool {
        if let url = URL(string: "yelp:") {
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
    
    static func getURL(_ identifier: String) -> URL? {
        if YelpPark.yelpIsInstalled() == true {
            return URL(string: "yelp:///biz/\(identifier)")
        } else {
            return URL(string: "https://www.yelp.com/biz/\(identifier)")
        }
    }
}
