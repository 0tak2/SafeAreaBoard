//
//  MainTabView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var tabRouter: TabRouter
    
    private var boardViewModel: BoardViewModel
    
    init(tabRouter: TabRouter, boardViewModel: BoardViewModel) {
        self._tabRouter = StateObject(wrappedValue: tabRouter)
        self.boardViewModel = boardViewModel
    }
    
    var body: some View {
        TabView(selection: $tabRouter.currentTab) {
            Tab("보드", systemImage: "square.stack", value: .board) {
                BoardView(viewModel: boardViewModel)
            }
            
            Tab("설정", systemImage: "gearshape", value: .setting) {
                SettingView()
            }
        }
        .tint(CustomColors.primaryDarker2)
    }
}
