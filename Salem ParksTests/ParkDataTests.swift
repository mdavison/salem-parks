//
//  ParkDataTests.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest
@testable import Salem_Parks

class ParkDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetMapAnnotations() {
        let parkData = ParkData()
        let annotations = parkData.getMapAnnotations()
        XCTAssertTrue(annotations.count == 80)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
