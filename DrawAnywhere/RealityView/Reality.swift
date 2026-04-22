//
//  RealityView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 08/04/2026.
//

import SwiftUI
#if canImport(UIKit) && canImport(ARKit)
import UIKit
import RealityKit
import ARKit

/// AR placement mode (iOS): tap surfaces (tables/walls) to place the image.
struct Reality: View {
    /// Pass the edited image from `EditView` / `.edit(let image)` here.
    let image: UIImage

    var body: some View {
        ARViewContainer(image: image)
            .ignoresSafeArea()
    }
}

private struct ARViewContainer: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false

        // World tracking + plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        context.coordinator.arView = arView
        context.coordinator.setImage(image)

        // Tap-to-place
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.setImage(image) // in case the image changes
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {
        weak var arView: ARView?

        private var imageEntity: ModelEntity?
        private var anchorEntity: AnchorEntity?

        func setImage(_ image: UIImage) {
            guard imageEntity == nil else { return }

            guard let cg = image.cgImage else { return }

            // Texture
            guard
                let texture = try? TextureResource.generate(
                    from: cg,
                    withName: "PlacedImageTexture",
                    options: .init(semantic: .color)
                )
            else { return }

            // Keep aspect ratio; choose a reasonable default size in meters.
            let aspect = Double(cg.width) / Double(cg.height)
            let heightMeters: Float = 0.25
            let widthMeters: Float = Float(aspect) * heightMeters

            let mesh = MeshResource.generatePlane(width: widthMeters, height: heightMeters)
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            material.faceCulling = .none

            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = "PlacedImage"

            // Let RealityKit generate collisions so taps/gestures can hit it later if needed
            entity.generateCollisionShapes(recursive: true)

            self.imageEntity = entity
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView, let imageEntity else { return }

            let location = recognizer.location(in: arView)

            // Prefer placing on real detected surfaces.
            // - Horizontal: tables/floors
            // - Vertical: walls
            // - Estimated fallback: when planes aren't detected yet
            let horizontalHit = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first
            let verticalHit = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .vertical).first
            let estimatedHit = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first
            guard let hit = horizontalHit ?? verticalHit ?? estimatedHit else { return }

            let anchor: AnchorEntity
            if let existingAnchorEntity = anchorEntity {
                anchor = existingAnchorEntity
                anchor.transform.matrix = hit.worldTransform
            } else {
                anchor = AnchorEntity(world: hit.worldTransform)
                anchor.addChild(imageEntity)
                arView.scene.addAnchor(anchor)
                anchorEntity = anchor
            }

            // Nudge the image slightly along the surface normal so it sits "on top" of the plane
            // (and avoids z-fighting with the detected surface).
            imageEntity.position = SIMD3<Float>(0, 0.005, 0)
        }
    }
}

#else
/// Fallback for platforms that don't support ARKit/ARView (e.g. visionOS/macOS builds in a multiplatform project).
struct Reality: View {
    let image: Image

    init(image: Image) {
        self.image = image
    }

    var body: some View {
        VStack(spacing: 12) {
            image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding()
            Text("AR placement is only available on iOS with ARKit.")
                .font(.headline)
            Text("Run on an iPhone/iPad device to place the image on tables and walls.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}
#endif
