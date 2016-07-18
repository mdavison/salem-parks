//
//  ParkTests.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest
@testable import Salem_Parks
import CoreData
import CoreLocation

class ParkTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coreDataStack = TestCoreDataStack()
        Park.saveJSONDataToCoreData(coreDataStack)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetFetchedResultsController() {
        let fetchedResultsController = Park.getFetchedResultsController(nil, category: nil, coreDataStack: coreDataStack)
        XCTAssertTrue(fetchedResultsController.fetchedObjects!.count == 80)
    }
    
    func testGetFetchedResultsControllerWithSearchText() {
        let fetchedResultsController = Park.getFetchedResultsController("river", category: nil, coreDataStack: coreDataStack)
        XCTAssertTrue(fetchedResultsController.fetchedObjects!.count == 2)
    }
    
    func testGetFetchedResultsControllerWithCategory() {
        let fetchedResultsController = Park.getFetchedResultsController(nil, category: 2, coreDataStack: coreDataStack)
        //print("number of parks with bathrooms: \(fetchedResultsController.fetchedObjects?.count)")
        XCTAssertTrue(fetchedResultsController.fetchedObjects!.count == 17)
    }
    
    func testGetFetchedResultsControllerWithSearchTextAndCategory() {
        let fetchedResultsController = Park.getFetchedResultsController("road", category: 1, coreDataStack: coreDataStack)
        XCTAssertTrue(fetchedResultsController.fetchedObjects!.count == 2)
    }
    
    func testGetAll() {
        let parks = Park.getAll(coreDataStack)
        XCTAssertTrue(parks!.count == 80)
    }
    
    func testGetParkForID() {
        let park = Park.getPark(forID: 86, coreDataStack: coreDataStack)
        XCTAssertTrue(park?.name == "West Salem Park")
    }
    
    // TODO: figure out how to test for notifications
//    func testGetCKPhotosFromiCloud() {
//        Park.getCKPhotosFromiCloud(forParkID: 86)
//        
//        NSNotificationCenter.defaultCenter().addObserverForName(
//            Notifications.fetchPhotosForParkFromiCloudFinishedNotification,
//            object: nil,
//            queue: NSOperationQueue.mainQueue()) { (notification) in
//
//                if let userInfo = notification.userInfo as? [String: [CKPhoto]], photos = userInfo["Photos"] {
//                    print("photos count: \(photos.count)")
//                }
//        }
//    }
    
    func testGetRegions() {
        let parkData = ParkData()
        let parkAnnotations = parkData.getMapAnnotations()
        let location = CLLocation(latitude: 44.9429, longitude: -123.0351)
        let regions = Park.getRegions(forAnnotations: parkAnnotations, currentLocation: location)
        XCTAssertTrue(regions.count == 20)
    }
    
    func testGetAmenities() {
        let park = Park.getPark(forID: 86, coreDataStack: coreDataStack)
        let amenities = park!.getAmenities()
        var dict = amenities[3]
        for (key, value) in dict {
            XCTAssertTrue(key == "Park Type")
            XCTAssertTrue(value == "Neighborhood Park")
        }
        dict = amenities[4]
        for (key, value) in dict {
            XCTAssertTrue(key == "Restrooms")
            XCTAssertTrue(value == "Yes")
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
