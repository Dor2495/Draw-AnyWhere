//
//  PhotoPreviewView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 28/03/2026.
//

import SwiftUI
internal import AVFoundation

struct PhotoPreviewView: View {
    let item: IdentifiableImage
    let onDismiss: () -> Void
    let onSave: (UIImage) -> Void
    
    init(item: IdentifiableImage, onDismiss: @escaping () -> Void, onSave: @escaping (UIImage) -> Void) {
        self.item = item
        self.onDismiss = onDismiss
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Retake") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Button("Save") {
                    UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil)
                    onSave(item.image)
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            Image(uiImage: item.image)
                .resizable()
                .scaledToFit()
            
            Spacer()
        }
    }
}
