//
//  TaskWithLoadingModifier.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/22/25.
//

import Foundation
import SwiftUI

struct LoadingViewModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                Color.clear
            }
            content
        }
    }
}

extension View {
    public func loading(isLoading: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
