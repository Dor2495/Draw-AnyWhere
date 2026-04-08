//
//  DropImageView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 08/04/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropImageView: View {
    var model: ContentModel
    @State private var uiImage: UIImage?


    var body: some View {
        
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 3.0, dash: [9.0, 14.0]))
            .frame(maxWidth: .infinity, minHeight: 350, maxHeight: 400)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding()
            .foregroundStyle(.blue)
        
        .overlay {
            PasteButton(supportedContentTypes: [.image]) { providers in
                guard let provider = providers.first else { return }

                _ = provider.loadTransferable(type: Data.self) { result in
                    guard let data = try? result.get(),
                          let image = UIImage(data: data)
                    else { return }

                    Task { @MainActor in
//                        uiImage = image
                        model.screen = .imageReview(image)
//                        await model.pickImage(image)
                    }
                }
            }
            .padding()
        }
    }
}
#Preview {
    DropImageView(model: ContentModel())
}
