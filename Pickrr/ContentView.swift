//
//  ContentView.swift
//  Pickr
//
//  Created by Muhammad Saad on 2026-01-13.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var t: Double = 0

    var body: some View {
        ZStack {
            // Cinematic gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2 + 0.15 * sin(t),
                          green: 0.1,
                          blue: 0.6 + 0.15 * cos(t)),
                    Color(red: 0.1,
                          green: 0.5 + 0.15 * cos(t),
                          blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
                    t += 0.01
                }
            }

            NoiseView()

            TouchViewRepresentable()
        }
    }
}

struct TouchViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TouchView {
        TouchView()
    }
    func updateUIView(_ uiView: TouchView, context: Context) {}
}

// Film grain
struct NoiseView: View {
    @State private var tick = 0

    var body: some View {
        Image(uiImage: generateNoise())
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .opacity(0.05)
            .blendMode(.overlay)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
                    tick += 1
                }
            }
    }

    func generateNoise() -> UIImage {
        let size = CGSize(width: 300, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            for _ in 0..<5000 {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let a = CGFloat.random(in: 0.05...0.15)
                UIColor.white.withAlphaComponent(a).setFill()
                ctx.cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }
}
