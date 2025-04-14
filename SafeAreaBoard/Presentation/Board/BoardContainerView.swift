//
//  BoardContainerView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/14/25.
//

import SwiftUI

struct BoardContainerView: View {
    @StateObject private var viewModel: BoardViewModel
    @StateObject private var navigationRouter: BoardNavigationRouter
    @EnvironmentObject private var container: DIContainerEnvironment
    
    init(viewModel: BoardViewModel, navigationRouter: BoardNavigationRouter = BoardNavigationRouter()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigationRouter = StateObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.paths) {
            BoardContentView(viewModel: viewModel)
                .onAppear() {
                    viewModel.navigationRouter = navigationRouter // is it best?
                }
                .navigationDestination(for: BoardNavigationRouter.Path.self) { path in
                    switch path {
                    case .edit(let question, let postOrNil):
                        let wrtieViewModel = container.resolve(WriteViewModel.self)!
                        wrtieViewModel.navigationRouter = navigationRouter
                        
                        if let post = postOrNil {
                            wrtieViewModel.configure(isEditMode: true, question: question, post: post)
                        } else {
                            wrtieViewModel.configure(isEditMode: false, question: question, post: nil)
                        }
                        return WriteView(viewModel: wrtieViewModel)
                    }
                }
        }
    }
}
