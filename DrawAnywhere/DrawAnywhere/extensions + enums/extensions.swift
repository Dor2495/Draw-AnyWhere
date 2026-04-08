//
//  GlassStyle.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 02/04/2026.
//

import SwiftUI

extension View {
    func glassDock() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 12, y: 8)
    }

    func glassCapsule(tint: Color = .white.opacity(0.12)) -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tint, in: Capsule())
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 1))
    }
    
    func imageReviewToolbar(
          transitionTo: @escaping (() -> Void),
          confirm: @escaping (() -> Void)
          
    ) -> some View {
        toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    transitionTo()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    confirm()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    func editReviewToolbar(
          transitionTo: @escaping (() -> Void)
    ) -> some View {
        toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    transitionTo()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
