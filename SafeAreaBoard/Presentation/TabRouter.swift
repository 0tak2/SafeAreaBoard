//
//  TabNavigator.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import Foundation

final class TabRouter: ObservableObject {
    enum Tab: Hashable {
        case board
        case new
        case setting
    }
    
    @Published var currentTab: Tab = .board
}
