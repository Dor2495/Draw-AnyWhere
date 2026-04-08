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
                }
                .tabViewBottomAccessory {
                    HStack(spacing: 10) {
                        Button {
//                            delegate.rotateAction()
                        } label: {
                            Label("Rotate", systemImage: "rotate.right.fill")
                        }
                        .glassCapsule()

                        Button(role: .destructive) {
        //                    retakeAction()
                        } label: {
                            Label("Retake", systemImage: "arrow.counterclockwise")
                        }
                        .glassCapsule(tint: .red.opacity(0.16))
                        
                        Button(role: .close) {
                            Task {
                                withAnimation(.spring) {
        //                            isEditVisible = false
                                }
                            }
                        } label: {
                            Label("Hide", systemImage: "xmark")
                        }
                        .glassCapsule(tint: .red.opacity(0.16))
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        switch model.screen {
        case .gallery:
            ToolbarItem(placement: .automatic) {
                
            }

        case .imageReview:
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    transitionToGallery()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    confirmImageAndEnterEdit()
                } label: {
                    Image(systemName: "checkmark")
                }
            }

        case .edit:
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    transitionToGallery()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
    
    private func transitionToGallery() {
        model.selectedImage = nil
        model.selectedTab = .gallery
        resetTransforms()
        model.screen = .gallery
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
