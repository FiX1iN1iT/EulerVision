//
//  EulerAnglesView.swift
//  EulerVision
//
//  Created by Alexander on 29.04.2025.
//

import SwiftUI

struct EulerAnglesView: View {
    @State private var pitch: Double = 0
    @State private var yaw: Double = 0
    @State private var roll: Double = 0
    @State private var frequencyText: String = "Frequency: --°/s"

    private let frequencyCalculator = FrequencyCalculator()

    var body: some View {
        VStack {
            // AR-View
            FaceTrackingView(pitch: $pitch, yaw: $yaw, roll: $roll)
                .frame(height: 400)
                .edgesIgnoringSafeArea(.all)

            // Углы Эйлера
            VStack(spacing: 10) {
                Text("Pitch (X): \(pitch, specifier: "%.1f")°").foregroundColor(.red)
                Text("Yaw (Y): \(yaw, specifier: "%.1f")°").foregroundColor(.green)
                Text("Roll (Z): \(roll, specifier: "%.1f")°").foregroundColor(.blue)
            }
            .font(.title2)
            .padding()

            // Частота изменений
            Text(frequencyText)
                .font(.headline)
                .onChange(of: pitch) { updateFrequency() }
        }
    }

    private func updateFrequency() {
        if let (dp, dy, dr, dt) = frequencyCalculator.calculateFrequency(pitch: pitch, yaw: yaw, roll: roll) {
            let freqPitch = dp / dt
            let freqYaw = dy / dt
            let freqRoll = dr / dt

            frequencyText = String(format: "ΔPitch: %.1f°/s, ΔYaw: %.1f°/s, ΔRoll: %.1f°/s", freqPitch, freqYaw, freqRoll)
        }
    }
}
