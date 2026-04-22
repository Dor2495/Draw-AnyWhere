//
//  Content.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI
import PhotosUI


struct TabViewContentView: View {
    
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var model: ContentModel
    
    var body: some View {
         NavigationStack {
            switch model.screen {
            case .gallery:
                GalleryView(cameraManager: cameraManager, model: model)
                    
            case .imageReview(let image):
                ImageReviewView(image: image)
                    .imageReviewToolbar {
                        transitionToGallery()
                    } confirm: {
                        confirmImageAndEnterEdit()
                    }
                
            case .edit(let image):
                EditView(
                    cameraManager: cameraManager,
                    model: model,
                    image: image
                )
                .editReviewToolbar {
                    transitionToGallery()
                } filters: {
                    model.filters.toggle()
                }
            }
        }
    }
    
    private func transitionToGallery() {
        model.errors = ErrorsModel(
            isPresenting: true,
            title: "Are you sure that you want to dismiss the current proccess?",
            error: "The current image will be dismissed.",
            confirmation: {
                model.selectedImage = nil
                model.selectedTab = .gallery
                resetTransforms()
                model.screen = .gallery
            }
        )
    }

    private func confirmImageAndEnterEdit() {
        guard
            case .imageReview(let image) = model.screen else { return }
        
        model.screen = .edit(image)
    }
    
    private func resetTransforms() {
        model.baseOffset = .zero
        model.baseZoom = 1.0
        model.baseRotation = 0
        model.opacity = 0.35
    }
}

#Preview {
    ContentView()
}
