//
//  BoardContainerView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/14/25.
//

import SwiftUI
import SpriteKit
import os.log

struct BoardContainerView: View {
    @StateObject private var viewModel: BoardViewModel
    @StateObject private var navigationRouter: NavigationRouter
    
    private let log = Logger.of("BoardContainerView")
    
    init(viewModel: BoardViewModel, navigationRouter: NavigationRouter = NavigationRouter()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigationRouter = StateObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.paths) {
            ZStack {
                if viewModel.showingHeartParticle {
                    GeometryReader { proxy in
                        SpriteView(scene: HeartEffectScene(size: proxy.size), options: [.allowsTransparency])
                    }
                }
                
                BoardContentView(viewModel: viewModel, navigationRouter: navigationRouter)
            }
            .animation(.smooth, value: viewModel.showingHeartParticle)
            .navigationDestination(for: NavigationRouter.Path.self) { path in
                switch path {
                case .edit(let question, let postOrNil):
                    WriteView(
                        viewModel: Resolver.resolve { resolved in
                            if let post = postOrNil {
                                resolved.configure(isEditMode: true, question: question, post: post)
                            } else {
                                resolved.configure(isEditMode: false, question: question, post: nil)
                            }
                        },
                        navigationRouter: navigationRouter
                    )
                default:
                    Text("not supported path in current context")
                }
            }
        }
    }
}
