//
//  GalleryView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI
import PhotosUI

struct GalleryView: View {
    
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var model:ContentModel
    
    @State private var filters: Bool = false

    init(cameraManager: CameraManager, model: ContentModel) {
        self.cameraManager = cameraManager
        self.model = model
    }
    
    var body: some View {
        TabView(selection: $model.selectedTab) {
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                CaptureButton { cameraManager.capturePhoto() }
            }
            .tag(RootTab.camera)
            .tabItem { Label("Camera", systemImage: "camera") }
            
            VStack(alignment: .center, spacing: 40) {
                DropImageView(model: model)
                
                PhotosPicker(
                    selection: $model.selectedImage,
                    matching: .images
                ) {
                    Label("Select image", systemImage: "photo.on.rectangle.angled")
                        .padding()
                        .glassEffect(.regular, in: .capsule)
                }
            }
            .tag(RootTab.gallery)
            .tabItem { Label("Gallery", systemImage: "photo.on.rectangle.angled") }
        }
    }
}

#Preview {
    ContentView()
}
