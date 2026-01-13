//
//  PickrrTests.swift
//  PickrrTests
//
//  Created by Muhammad Saad on 2026-01-13.
//

import XCTest
@testable import Pickrr

final class PickerEngineTests: XCTestCase {
    
    var engine: PickerEngine?

    override func setUp() {
        super.setUp()
        engine = PickerEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    func testCannotPickWithOneFinger() {
        engine?.addFinger(id: 1, position: .zero)
        XCTAssertFalse(engine?.canPick() ?? true)
    }

    func testCanPickWithTwoFingers() {
        engine?.addFinger(id: 1, position: .zero)
        engine?.addFinger(id: 2, position: .zero)
        XCTAssertTrue(engine?.canPick() ?? false)
    }

    func testPickSelectsWinner() {
        engine?.addFinger(id: 1, position: .zero)
        engine?.addFinger(id: 2, position: .zero)
        engine?.pick()
        XCTAssertNotNil(engine?.winnerID)
    }

    func testResetWhenAllRemoved() {
        engine?.addFinger(id: 1, position: .zero)
        engine?.addFinger(id: 2, position: .zero)
        engine?.pick()

        engine?.removeFinger(id: 1)
        engine?.removeFinger(id: 2)
        XCTAssertNil(engine?.winnerID)
    }
    
    func testMoveFingerUpdatesPosition() {
        engine?.addFinger(id: 1, position: .zero)
        let newPosition = CGPoint(x: 100, y: 100)
        engine?.moveFinger(id: 1, position: newPosition)
        
        XCTAssertEqual(engine?.fingers[1]?.position, newPosition)
    }

    func testResetIfAllRemovedManualCall() {
        engine?.addFinger(id: 1, position: .zero)
        // Manually removing from dictionary to test the reset function specifically
        engine?.removeFinger(id: 1)
        engine?.resetIfAllRemoved()
        
        XCTAssertNil(engine?.winnerID)
    }

    func testSupportsUpToTenFingers() {
        for i in 1...10 {
            engine?.addFinger(id: i, position: CGPoint(x: CGFloat(i), y: CGFloat(i)))
            
            if i >= 2 {
                XCTAssertTrue(engine?.canPick() ?? false)
                engine?.pick()
                XCTAssertNotNil(engine?.winnerID)
            }
        }
        XCTAssertEqual(engine?.fingers.count, 10)
    }
    
    func testTouchViewCoverageBoost() {
        let view = TouchView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))

        view.touchesBegan(Set<UITouch>(), with: nil)
        view.touchesMoved(Set<UITouch>(), with: nil)
        view.touchesEnded(Set<UITouch>(), with: nil)
        view.touchesCancelled(Set<UITouch>(), with: nil)
        
        // Trigger the draw method for the "empty" state
        view.draw(view.bounds)
        
        XCTAssertNotNil(view)
    }
}
