//
//  MainTabView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var tabRouter: TabRouter
    @EnvironmentObject var container: DIContainerEnvironment
    
    private var boardViewModel: BoardViewModel
    private var writeViewModel: WriteViewModel
    
    init(tabRouter: TabRouter, boardViewModel: BoardViewModel, writeViewModel: WriteViewModel) {
        self._tabRouter = StateObject(wrappedValue: tabRouter)
        self.boardViewModel = boardViewModel
        self.writeViewModel = writeViewModel
    }
    
    var body: some View {
        TabView(selection: $tabRouter.currentTab) {
            Tab("보드", systemImage: "square.stack", value: .board) {
                BoardView(viewModel: boardViewModel)
            }
            
            Tab("작성", systemImage: "bubble.and.pencil", value: .edit) {
                NavigationStack {
                    WriteView(viewModel: writeViewModel)
                }
            }
            
            Tab("설정", systemImage: "gearshape", value: .setting) {
                SettingView()
            }
        }
        .tint(CustomColors.primaryDarker2)
        .onAppear() { // FIXME: is it best?
            boardViewModel.tabRouter = self.tabRouter
            writeViewModel.tabRouter = self.tabRouter
        }
    }
}
