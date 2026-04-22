//
//  EditView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI

struct EditView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var model: ContentModel
    
    @Namespace private var controls
    
    var image: UIImage
    
    var body: some View {
        if #available(iOS 26.1, *) {
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(Double(model.baseRotation)))
                    .offset(model.baseOffset)
                    .opacity(model.opacity)
                    .scaleEffect(model.baseZoom)
                    .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
                    .padding(20)
            }
            .overlay(gestureOverlay)
            .sheet(isPresented: $model.filters) {
                ControllersView(model: model) {
                    withAnimation(.bouncy) {
                        model.baseRotation += 90
                    }
                }
                .presentationDetents([.height(250)])
            }
            .ignoresSafeArea()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder
    private var gestureOverlay: some View {
        TransformGestureBridge(
            zoom: $model.baseZoom,
            rotationDegrees: $model.baseRotation,
            offset: $model.baseOffset,
            minZoom: 0.5,
            maxZoom: 8.0
        )
    }
}

#Preview {
    ContentView()
}
