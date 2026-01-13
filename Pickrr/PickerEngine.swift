//
//  PickerEngine.swift
//  Pickrr
//
//  Created by Muhammad Saad on 2026-01-13.
//

import Foundation
import CoreGraphics

struct FingerState {
    let id: Int
    var position: CGPoint
}

final class PickerEngine {

    private(set) var fingers: [Int: FingerState] = [:]
    private(set) var winnerID: Int?

    func addFinger(id: Int, position: CGPoint) {
        fingers[id] = FingerState(id: id, position: position)
        winnerID = nil
    }

    func moveFinger(id: Int, position: CGPoint) {
        fingers[id]?.position = position
    }

    func removeFinger(id: Int) {
        fingers.removeValue(forKey: id)
        if fingers.isEmpty {
            winnerID = nil
        }
    }

    func canPick() -> Bool {
        fingers.count >= 2 && winnerID == nil
    }

    func pick() {
        guard canPick() else { return }
        winnerID = fingers.keys.randomElement()
    }

    func resetIfAllRemoved() {
        if fingers.isEmpty {
            winnerID = nil
        }
    }
}
