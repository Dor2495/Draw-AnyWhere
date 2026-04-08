//
//  AppStage.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 02/04/2026.
//

import SwiftUI


enum AppStage {
  case capture
  case edit
}

enum RootTab: Hashable {
    case camera
    case gallery
}

enum ScreenState: Equatable {
    case gallery
    case imageReview(UIImage)
    case edit(UIImage)
}
