//
//  ControllersView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 29/03/2026.
//

import SwiftUI

struct ControllersView: View {
    @ObservedObject var model: ContentModel

    let rotateAction: () -> Void

    var body: some View {
        editDock
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    
    private var editDock: some View {
        VStack(spacing: 17) {
            HStack {
                
                Spacer()
                Button(role: .destructive) {
                    model.filters = false
                } label: {
                    Image(systemName: "xmark")
                }
                .glassCapsule()
            }
            

            VStack(spacing: 17) {
                HStack {
                    Label("Opacity", systemImage: "circle.lefthalf.filled")
                    Slider(value: $model.opacity, in: 0.05...1.0, step: 0.05)
                    Text("\(Int(model.opacity * 100))%")
                        .monospacedDigit()
                }

                HStack {
                    Label("Zoom", systemImage: "plus.magnifyingglass")
                    Slider(value: $model.baseZoom, in: 1.0...6.0, step: 0.1)
                    Text(String(format: "%.1fx", model.baseZoom))
                        .monospacedDigit()
                }
                
                HStack {
                    Button {
                        rotateAction()
                    } label: {
                        Label("Rotate", systemImage: "rotate.right.fill")
                    }
                    .glassCapsule()
                    
                    Spacer()
                    
                    Button {
                        model.resetTransforms()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .glassCapsule()
                    
                }
            }
            .font(.subheadline.weight(.medium))
            .padding(.bottom)
        }
        .frame(minHeight: 250)
        .padding(14)
    }
}

#Preview {
    ControllersView(model: ContentModel(), rotateAction: {})
}
