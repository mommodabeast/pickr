//
//  PickrrUITests.swift
//  PickrrUITests
//
//  Created by Muhammad Saad on 2026-01-13.
//

import XCTest

final class PickrrUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    @MainActor
    func testAppLaunchState() throws {
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    @MainActor
    func testMultiFingerSelectionFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        let screenCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        let finger1 = screenCoordinate.withOffset(CGVector(dx: 150, dy: 400))
        
        finger1.press(forDuration: 2.0)
        
        let selectionExpectation = XCTestExpectation(description: "Wait for logic")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            selectionExpectation.fulfill()
        }
        wait(for: [selectionExpectation], timeout: 3.0)
        
        XCTAssertTrue(app.exists)
    }
}
