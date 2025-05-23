//
//  SafeAreaBoardApp.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/9/25.
//

import SwiftUI

@main
struct SafeAreaBoardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView(viewModel: DIContainerProvider.shared.container.resolve(AppViewModel.self)!)
                .environmentObject(DIContainerEnvironment())
        }
    }
}
