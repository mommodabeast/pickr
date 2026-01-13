//
//  TouchView.swift
//  Pickr
//
//  Created by Muhammad Saad on 2026-01-13.
//

import UIKit
import AVFoundation

final class TouchView: UIView {

    struct Finger {
        let id: Int
        var location: CGPoint
    }

    private var fingers: [UITouch: Finger] = [:]
    private var nextID = 0
    private var selectedFingerID: Int?

    private var selectionTimer: Timer?
    private var pulsePhase: CGFloat = 0
    private var pulseTimer: CADisplayLink?
    private var displayLink: CADisplayLink?

    private var rippleCenter: CGPoint?
    private var rippleRadius: CGFloat = 0

    private var player: AVAudioPlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear

        displayLink = CADisplayLink(target: self, selector: #selector(redraw))
        displayLink?.add(to: .main, forMode: .common)

        if let url = Bundle.main.url(forResource: "winner", withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            fingers[t] = Finger(id: nextID, location: t.location(in: self))
            nextID += 1
        }
        selectedFingerID = nil
        stopPulse()
        schedulePick()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            fingers[t]?.location = t.location(in: self)
        }
        schedulePick()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { fingers.removeValue(forKey: t) }
        if fingers.isEmpty {
            selectedFingerID = nil
            stopPulse()
            rippleCenter = nil
        }
        schedulePick()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: Picking
    private func schedulePick() {
        selectionTimer?.invalidate()
        if fingers.count < 2 || selectedFingerID != nil { return }

        selectionTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
            self.pickWinner()
        }
    }

    private func pickWinner() {
        guard selectedFingerID == nil, !fingers.isEmpty else { return }

        guard let winner = fingers.values.randomElement() else { return }
        
        selectedFingerID = winner.id
        rippleCenter = winner.location
        rippleRadius = 0

        fireHaptics()
        player?.currentTime = 0
        player?.play()
        startPulse()
    }

    // MARK: Haptics

    private func fireHaptics() {
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let rigid = UIImpactFeedbackGenerator(style: .rigid)
        heavy.prepare(); rigid.prepare()
        heavy.impactOccurred(intensity: 0.9)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            rigid.impactOccurred(intensity: 1.0)
        }
    }

    // MARK: Pulse

    private func startPulse() {
        pulseTimer?.invalidate()
        pulseTimer = CADisplayLink(target: self, selector: #selector(updatePulse))
        pulseTimer?.add(to: .main, forMode: .common)
    }

    private func stopPulse() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        pulsePhase = 0
    }

    @objc private func updatePulse() {
        pulsePhase += 0.15
        rippleRadius += 12
    }

    @objc private func redraw() {
        setNeedsDisplay()
    }

    // MARK: Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        if fingers.isEmpty {
            let text = "Place your fingers"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let size = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: bounds.midX - size.width/2, y: bounds.midY - size.height/2), withAttributes: attrs)
            return
        }

        // Ripple
        if let center = rippleCenter {
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            ctx.setLineWidth(2)
            ctx.addEllipse(in: CGRect(x: center.x - rippleRadius, y: center.y - rippleRadius, width: rippleRadius*2, height: rippleRadius*2))
            ctx.strokePath()
        }

        for f in fingers.values {
            let winner = f.id == selectedFingerID
            let base: CGFloat = 44
            let pulse = winner ? sin(pulsePhase) * 12 : 0
            let r = base + pulse
            let alpha: CGFloat = winner ? 1.0 : 0.3
            let line: CGFloat = winner ? 7 : 3

            if winner {
                ctx.setShadow(offset: .zero, blur: 25, color: UIColor.white.cgColor)
            } else {
                ctx.setShadow(offset: .zero, blur: 0, color: nil)
            }

            ctx.setStrokeColor(UIColor.white.withAlphaComponent(alpha).cgColor)
            ctx.setLineWidth(line)
            ctx.addEllipse(in: CGRect(x: f.location.x - r, y: f.location.y - r, width: r*2, height: r*2))
            ctx.strokePath()
        }
    }
}
