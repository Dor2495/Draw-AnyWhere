////
////  NewContentView.swift
////  DrawAnywhere
////
////  Created by Dor Mizrachi on 03/04/2026.
////
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var model: ContentModel = ContentModel()

    var body: some View {
        
        let screenNeedsCamera: Bool = {
            switch model.screen {
            case .edit:
                return true
            case .gallery:
                return model.selectedTab == .camera
            case .imageReview:
                return false
            }
        }()
        let shouldRun: Bool = {
            scenePhase == .active &&
            cameraManager.authorizationStatus == .authorized &&
            screenNeedsCamera
        }()
        
        TabViewContentView(
            cameraManager: cameraManager,
            model: model
        )
        .task {
            checkAuthorizationAndUpdateCameraSessionPolicy(shouldRun)
        }
        .onChange(of: cameraManager.capturedImage) { _, newValue in
            guard let newValue else { return }
            let image = IdentifiableImage(image: newValue.image)
            model.screen = .imageReview(image.image)
        }
        .onChange(of: scenePhase) { _, _ in
            model.updateCameraSessionPolicy(
                cameraManager: cameraManager, shouldRun: shouldRun)
        }
        
        .onChange(of: model.screen) { _, _ in
            model.updateCameraSessionPolicy(
                cameraManager: cameraManager, shouldRun: shouldRun)
        }
        
        .onChange(of: model.selectedTab) { _, _ in model.updateCameraSessionPolicy(
            cameraManager: cameraManager, shouldRun: shouldRun) }
        
        .onChange(of: cameraManager.authorizationStatus) { _, _ in model.updateCameraSessionPolicy(
            cameraManager: cameraManager, shouldRun: shouldRun) }
        
        .onChange(of: model.selectedImage) { _, item in
            Task { await model.handlePickedImage(item) }
        }
        .animation(.snappy(duration: 0.28), value: model.screen)
    }
    
    private func checkAuthorizationAndUpdateCameraSessionPolicy(_ shouldRun: Bool) {
        cameraManager.checkAuthorization()
        model.updateCameraSessionPolicy(
            cameraManager: cameraManager, shouldRun: shouldRun)
    }
}

#Preview {
    ContentView()
}
