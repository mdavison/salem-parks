//
//  Salem_ParksUITests.swift
//  Salem ParksUITests
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest

class Salem_ParksUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewParkDetail() {
        let app = XCUIApplication()
        XCTAssert(app.navigationBars.staticTexts["List"].exists)
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Riverfront Park"].tap()
        XCTAssert(app.navigationBars.staticTexts["Riverfront Park"].exists)
        XCTAssert(app.scrollViews.otherElements.containingType(.StaticText, identifier:"200 Water St NE").element.exists)
    }
    
    func testParkImages() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Riverfront Park"].tap()
        let inProgressActivityIndicator = app.scrollViews.otherElements.collectionViews.activityIndicators["In progress"]
        XCTAssert(inProgressActivityIndicator.exists)
        XCTAssert(app.scrollViews.otherElements.images["Placeholder"].exists)
        
        // Assert that there is only 1 image to start
        XCTAssert(app.scrollViews.otherElements.collectionViews.cells.count == 1)
        
        // 3 images will be loaded asynchonously
        let lastImage = app.scrollViews.otherElements.collectionViews.cells.images.elementBoundByIndex(2)
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectationForPredicate(existsPredicate, evaluatedWithObject: lastImage, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testFavoritingPark() {
        let app = XCUIApplication()
        app.tables.staticTexts["Aldrich Park"].tap()
        app.scrollViews.otherElements.buttons["Like"].tap()
        XCTAssert(app.scrollViews.otherElements.buttons["Like Filled"].exists)
        // Reset the button for next time
        app.scrollViews.otherElements.buttons["Like Filled"].tap()
    }
    
    func testAmenitiesListExists() {
        let app = XCUIApplication()
        app.tables.staticTexts["Aldrich Park"].tap()
        XCTAssert(app.scrollViews.tables.staticTexts["Reservable"].exists)
        XCTAssert(app.scrollViews.tables.cells.elementBoundByIndex(21).staticTexts["No"].exists)
    }
    
    func testSearch() {
        let app = XCUIApplication()
        app.searchFields["Search by park name"].tap()
        app.typeText("River\r")
        XCTAssert(app.tables.cells.count == 2)
    }
    
    func testViewMap() {
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        XCTAssert(app.navigationBars.staticTexts["Map"].exists)
    }
    
    func testAnnotationsExist() {
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        XCTAssert(app.otherElements["Ellen Lane Property, 3101 Garrett St NW"].exists)
        XCTAssert(app.otherElements["Brush College Park, 2600 Doaks Ferry Rd NW"].exists)
        XCTAssert(app.otherElements["Grice Hill Property, 2201 27th Pl NW"].exists)
    }
    
    func testNearbyButton() {
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        app.navigationBars["Map"].buttons["Near Me"].tap()
        XCTAssert(app.navigationBars["Map"].buttons["Near Me Filled"].exists)
        app.navigationBars["Map"].buttons["Near Me Filled"].tap()
        XCTAssertFalse(app.navigationBars["Map"].buttons["Near Me Filled"].exists)
        XCTAssert(app.navigationBars["Map"].buttons["Near Me"].exists)
    }
    
    func testAnnotationRightCalloutAccessoryTapped() {
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        let ellenLaneAnnotation = app.otherElements["Ellen Lane Property, 3101 Garrett St NW"]
        ellenLaneAnnotation.tap()
        XCTAssert(ellenLaneAnnotation.exists)
        // Go to detail view
        app.buttons["More Than"].tap()
        let addressLabel = app.scrollViews.otherElements.staticTexts["3101 Garrett St NW"]
        addressLabel.tap()
        XCTAssert(addressLabel.exists)
        XCTAssertFalse(ellenLaneAnnotation.exists)
        // Go back to map view
        app.navigationBars["Ellen Lane Property"].buttons["Map"].tap()
        XCTAssert(app.navigationBars["Map"].exists)
        //XCTAssert(ellenLaneAnnotation.exists)
    }
    
    func testAnnotationLeftCalloutAccessoryTapped() {
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        app.otherElements["Ellen Lane Property, 3101 Garrett St NW"].tap()
        app.buttons["Car"].tap()
    }
    
}
