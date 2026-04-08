//
//  CaptureButton.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI

struct CaptureButton: View {
    let captureAction: () -> Void
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 62, height: 62)
                    .padding(5)
                    .glassEffect(.clear)
                Button {
                    captureAction()
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 62, height: 62)
                }
            }
            .safeAreaPadding()
        }
    }
}

#Preview {
    CaptureButton() { }
}
