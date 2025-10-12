//
//  MDTUITests.swift
//  MDTUITests
//
//  Created by Maksym Kershengolts on 18.05.19.
//  Copyright © 2019 Maksym Kershengolts. All rights reserved.
//

import XCTest

class MDTUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
    }

    func testExample() {
        app.launch()
        let cell = app.collectionViews.cells.firstMatch
        let fromCoordinate = cell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let toCoordinate = cell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 10))
        fromCoordinate.press(forDuration: 0.1, thenDragTo: toCoordinate)
        if !app.collectionViews.cells.firstMatch.waitForExistence(timeout: 5) {
            XCTFail("No data was loaded")
        }
    }

}
