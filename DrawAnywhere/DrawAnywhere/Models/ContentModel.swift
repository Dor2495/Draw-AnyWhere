//
//  ContentModel.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI
import Combine
import PhotosUI

class ContentModel: ObservableObject {
    
    // Overlay transform state (single source of truth)
    @Published var baseZoom: CGFloat = 1.0
    @Published var baseRotation: CGFloat = 0
    @Published var baseOffset: CGSize = .zero
    @Published var opacity: Double = 0.35

    @Published var selectedImage: PhotosPickerItem?
    @Published var selectedTab: RootTab = .gallery
    @Published var screen: ScreenState = .gallery
    
    func resetTransforms() {
        baseOffset = .zero
        baseZoom = 1.0
        baseRotation = 0
        opacity = 0.35
    }
    
    func pickImage(_ image: UIImage) async {
        selectedImage = nil
        resetTransforms()
        Task { @MainActor in
            screen = .imageReview(image)
        }
    }
    
    func updateCameraSessionPolicy(cameraManager: CameraManager, shouldRun: Bool) {
        if shouldRun {
            cameraManager.startSession()
        } else {
            cameraManager.stopSession()
        }
    }
    
    func handlePickedImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard
            let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data)
        else { return }

        await pickImage(image)
    }
    
}
