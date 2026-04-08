//
//  ControllersView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 29/03/2026.
//

import SwiftUI

struct ControllersView: View {
    
    @Binding var isEditVisible: Bool
    @Binding var stage: AppStage
    @Binding var opacityValue: Double
    @Binding var zoomValue: Double

    
    let captureAction: () -> Void
    let rotateAction: () -> Void
    let retakeAction: () -> Void

    var body: some View {
        Group {
            if stage == .capture {
                captureDock
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if isEditVisible {
                editDock
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.3), value: stage)
    }

    private var captureDock: some View {
        HStack {
            Button(action: captureAction) {
                ZStack {
                    Circle()
                        .strokeBorder(.white.opacity(0.95), lineWidth: 3)
                        .frame(width: 74, height: 74)
                    Circle()
                        .fill(.white)
                        .frame(width: 62, height: 62)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .glassDock()
    }

    private var editDock: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    rotateAction()
                } label: {
                    Label("Rotate", systemImage: "rotate.right.fill")
                }
                .glassCapsule()

                Button(role: .destructive) {
                    retakeAction()
                } label: {
                    Label("Retake", systemImage: "arrow.counterclockwise")
                }
                .glassCapsule(tint: .red.opacity(0.16))
                
                Button(role: .close) {
                    Task {
                        withAnimation(.spring) {
                            isEditVisible = false
                        }
                    }
                } label: {
                    Label("Hide", systemImage: "xmark")
                }
                .glassCapsule(tint: .red.opacity(0.16))
            }

            VStack(spacing: 8) {
                HStack {
                    Label("Opacity", systemImage: "circle.lefthalf.filled")
                    Slider(value: $opacityValue, in: 0.05...1.0, step: 0.05)
                    Text("\(Int(opacityValue * 100))%")
                        .monospacedDigit()
                }

                HStack {
                    Label("Zoom", systemImage: "plus.magnifyingglass")
                    Slider(value: $zoomValue, in: 1.0...6.0, step: 0.1)
                    Text(String(format: "%.1fx", zoomValue))
                        .monospacedDigit()
                }
            }
            .font(.subheadline.weight(.medium))
        }
        .padding(14)
        .glassDock()
    }
}
