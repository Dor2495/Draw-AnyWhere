//
//  ImageReviewView.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 06/04/2026.
//

import SwiftUI

struct ImageReviewView: View {
    
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
