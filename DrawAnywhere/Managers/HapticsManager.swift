//
//  HapticsManager.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 30/03/2026.
//

import Combine
import SwiftUI
import CoreHaptics

class HapticsManager: ObservableObject {
    
    private var engine: CHHapticEngine?
    
    init() {
        prepareEngine()
    }
    
    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Engine Error: \(error)")
        }
    }
    
    func playCaptureHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            var events = [CHHapticEvent]()

            // create one intense, sharp tap
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            events.append(event)
            
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [])
            
            let player = try engine?.makePlayer(with: pattern)
            
            try player?.start(atTime: 0)
        } catch {
            print("Haptic Error: \(error)")
        }
    }

    func playHeartbeat() {
        // 2. Define the "Lub" (First hit)
        let lub = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1) // Soft/Dull
            ],
            relativeTime: 0
        )

        // 3. Define the "Dub" (Second hit, slightly later and softer)
        let dub = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ],
            relativeTime: 0.15 // 150ms after the first
        )
        
//        let longBuzz = CHHapticEvent(
//            eventType: .hapticContinuous,
//            parameters: [
//                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
//                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
//            ],
//            relativeTime: 0.30,
//            duration: 0.5 // half a second
//        )

        do {
            // 4. Wrap in a pattern and play
            let pattern = try CHHapticPattern(events: [lub, dub], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
}
