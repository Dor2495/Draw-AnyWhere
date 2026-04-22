//
//  ErrorsModel.swift
//  DrawAnywhere
//
//  Created by Dor Mizrachi on 22/04/2026.
//

import SwiftUI
import Combine

struct ErrorsModel {
    
    var isPresenting: Bool = false
    var title: String? = nil
    var error: String? = nil
    
    var confirmation: (() -> Void)?
    var cancel: (() -> Void)?
    
    init(
        isPresenting: Bool = false,
        title: String? = nil,
        error: String? = nil,
        confirmation: (() -> Void)? = nil,
        cancel: (() -> Void)? = nil
    ) {
        self.isPresenting = isPresenting
        self.title = title
        self.error = error
        self.confirmation = confirmation
        self.cancel = cancel
    }
}
