//
//  NavigationRouter.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/14/25.
//

import Foundation

final class NavigationRouter: ObservableObject {
    @Published var paths: [Path] = []
    
    enum Path: Hashable {
        case edit(Question, Post?)
        case myPosts
    }
}
