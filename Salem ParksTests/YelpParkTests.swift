//
//  YelpParkTests.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest
@testable import Salem_Parks

class YelpParkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBusinessIDForParkID() {
        var businessID = YelpPark.getBusinessIDForParkID(48)
        XCTAssertTrue(businessID == "riverfront-park-salem")
        businessID = YelpPark.getBusinessIDForParkID(86)
        XCTAssertTrue(businessID == nil)
    }
    
    func testYelpIsInstalled() {
        let yelpIsInstalled = YelpPark.yelpIsInstalled()
        XCTAssertTrue(yelpIsInstalled == false)
    }
    
    func testGetURL() {
        let url = YelpPark.getURL("riverfront-park-salem")
        XCTAssertTrue(url?.absoluteString == "https://www.yelp.com/biz/riverfront-park-salem")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
