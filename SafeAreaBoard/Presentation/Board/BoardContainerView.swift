//
//  BoardContainerView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/14/25.
//

import SwiftUI
import os.log

struct BoardContainerView: View {
    @StateObject private var viewModel: BoardViewModel
    @StateObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var container: DIContainerEnvironment
    
    private let log = Logger.of("BoardContainerView")
    
    init(viewModel: BoardViewModel, navigationRouter: NavigationRouter = NavigationRouter()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigationRouter = StateObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.paths) {
            BoardContentView(viewModel: viewModel)
                .onAppear() {
                    viewModel.navigationRouter = navigationRouter // is it best?
                }
                .navigationDestination(for: NavigationRouter.Path.self) { path in
                    switch path {
                    case .edit(let question, let postOrNil):
                        WriteView(viewModel: resolveWirteViewModel(question: question, post: postOrNil))
                    default:
                        Text("not supported path in current context")
                    }
                }
        }
    }
    
    func resolveWirteViewModel(question: Question, post: Post?) -> WriteViewModel {
        let wrtieViewModel = container.resolve(WriteViewModel.self)!
        wrtieViewModel.navigationRouter = navigationRouter
        
        if let post = post {
            wrtieViewModel.configure(isEditMode: true, question: question, post: post)
        } else {
            wrtieViewModel.configure(isEditMode: false, question: question, post: nil)
        }
        
        return wrtieViewModel
    }
}
