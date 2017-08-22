//
//  ParkAnnotationTests.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest
@testable import Salem_Parks
import MapKit

class ParkAnnotationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetCoordinate() {
        let coordinate = ParkAnnotation.getCoordinate(forParkID: 32) // Ellen Lane Property
        XCTAssertTrue(coordinate?.latitude == 44.9798066718336)
        XCTAssertTrue(coordinate?.longitude == -123.087883012112)
    }
    
    func testInit() {
        let coordinate = ParkAnnotation.getCoordinate(forParkID: 32)
        let parkAnnotation = ParkAnnotation(
            title: "Ellen Lane Property",
            locationName: "3101 Garrett St NW",
            discipline: "Open",
            coordinate: coordinate!,
            objectID: 32)
        XCTAssertTrue(parkAnnotation.title == "Ellen Lane Property")
        XCTAssert(parkAnnotation.isKindOfClass(ParkAnnotation))
    }
    
    func testMapItem() {
        let coordinate = ParkAnnotation.getCoordinate(forParkID: 32)
        let parkAnnotation = ParkAnnotation(
            title: "Ellen Lane Property",
            locationName: "3101 Garrett St NW",
            discipline: "Open",
            coordinate: coordinate!,
            objectID: 32)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        XCTAssertTrue(parkAnnotation.mapItem().openInMapsWithLaunchOptions(launchOptions))
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
