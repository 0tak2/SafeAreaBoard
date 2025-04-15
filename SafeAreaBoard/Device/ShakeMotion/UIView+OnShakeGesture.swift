//
//  UIView+OnShakeGesture.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/15/25.
//

import Foundation
import SwiftUI

struct OnShakeGesture: ViewModifier {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    public func onShakeGesture(_ action: @escaping () -> Void) -> some View {
        modifier(OnShakeGesture(action: action))
    }
}
