//
//  TransformGestureBridge.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI
import UIKit

final class GestureView: UIView {}

struct TransformGestureBridge: UIViewRepresentable {
    @Binding var zoom: CGFloat
    @Binding var rotationDegrees: CGFloat
    @Binding var offset: CGSize

    var minZoom: CGFloat = 0.5
    var maxZoom: CGFloat = 8.0

    func makeUIView(context: Context) -> GestureView {
        let view = GestureView()
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true

        let pinch = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )
        let rotation = UIRotationGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleRotation(_:))
        )
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )

        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 2

        pinch.delegate = context.coordinator
        rotation.delegate = context.coordinator
        pan.delegate = context.coordinator

        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(rotation)
        view.addGestureRecognizer(pan)

        context.coordinator.onUpdate = { zoomDelta, rotationDeltaRadians, panDelta in
            let nextZoom = zoom * zoomDelta
            zoom = min(max(nextZoom, minZoom), maxZoom)

            rotationDegrees += rotationDeltaRadians * 180 / .pi

            offset.width += panDelta.x
            offset.height += panDelta.y
        }

        return view
    }

    func updateUIView(_ uiView: GestureView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onUpdate: ((CGFloat, CGFloat, CGPoint) -> Void)?

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard gesture.state == .changed || gesture.state == .ended else { return }
            onUpdate?(gesture.scale, 0, .zero)
            gesture.scale = 1
        }

        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard gesture.state == .changed || gesture.state == .ended else { return }
            onUpdate?(1, gesture.rotation, .zero)
            gesture.rotation = 0
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let hostView = gesture.view else { return }
            guard gesture.state == .changed || gesture.state == .ended else { return }

            let translation = gesture.translation(in: hostView)
            onUpdate?(1, 0, translation)
            gesture.setTranslation(.zero, in: hostView)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}


