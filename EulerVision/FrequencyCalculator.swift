//
//  FrequencyCalculator.swift
//  EulerVision
//
//  Created by Alexander on 29.04.2025.
//

import Foundation

class FrequencyCalculator {
    private var lastUpdateTime: Date?
    private var lastPitch: Double = 0
    private var lastYaw: Double = 0
    private var lastRoll: Double = 0

    func calculateFrequency(pitch: Double, yaw: Double, roll: Double) -> (dp: Double, dy: Double, dr: Double, dt: Double)? {
        guard let lastTime = lastUpdateTime else {
            lastUpdateTime = Date()
            lastPitch = pitch
            lastYaw = yaw
            lastRoll = roll
            return nil
        }

        let currentTime = Date()
        let deltaTime = currentTime.timeIntervalSince(lastTime)

        guard deltaTime > 0 else { return nil }

        let deltaPitch = abs(pitch - lastPitch)
        let deltaYaw = abs(yaw - lastYaw)
        let deltaRoll = abs(roll - lastRoll)

        lastUpdateTime = currentTime
        lastPitch = pitch
        lastYaw = yaw
        lastRoll = roll

        return (deltaPitch, deltaYaw, deltaRoll, deltaTime)
    }
}
