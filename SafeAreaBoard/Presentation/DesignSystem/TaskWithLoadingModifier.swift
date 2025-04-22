//
//  TaskWithLoadingModifier.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/22/25.
//

import Foundation
import SwiftUI

struct TaskWithLoadingModifier: ViewModifier {
    var isLoading: Binding<Bool>
    var task: () async -> Void
    
    func body(content: Content) -> some View {
        content.task {
            isLoading.wrappedValue = true
            await task()
            isLoading.wrappedValue = false
        }
    }
}

extension View {
    public func task(isLoading: Binding<Bool>, task: @escaping () async -> Void) -> some View {
        modifier(TaskWithLoadingModifier(isLoading: isLoading, task: task))
    }
}
